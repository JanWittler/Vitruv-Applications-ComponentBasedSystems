package tools.vitruv.applications.external.strategies

import java.util.Set
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.compare.merge.BatchMerger
import org.eclipse.emf.compare.merge.IMerger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.VitruviusChangeFactory
import tools.vitruv.framework.change.recording.ChangeRecorder
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.domains.VitruvDomain
import tools.vitruv.framework.domains.repository.VitruvDomainRepository
import tools.vitruv.framework.domains.repository.VitruvDomainRepositoryImpl
import tools.vitruv.framework.uuid.UuidResolver

import static com.google.common.base.Preconditions.checkArgument
import static tools.vitruv.framework.uuid.UuidGeneratorAndResolverFactory.createUuidGeneratorAndResolver

import static extension edu.kit.ipd.sdq.commons.util.org.eclipse.emf.ecore.resource.ResourceUtil.getReferencedProxies
import static extension tools.vitruv.framework.domains.repository.DomainAwareResourceSet.awareOfDomains
import com.google.common.base.Stopwatch
import tools.vitruv.applications.external.umljava.tests.util.TimeMeasurement

/** A change resolution strategy that uses a @{link StateBasedDifferencesProvider} to compute the differences and replays them to convert them to a change sequence. */
class DifferencesReplayingStateBasedChangeResolutionStrategy implements StateBasedChangeResolutionStrategy {
	val StateBasedDifferencesProvider differencesProvider
	val VitruviusChangeFactory changeFactory
	val VitruvDomainRepository domainRepository

	/**
	 * Initializes the strategy using the given differences provider.
	 * @param differencesProvider The differences provider used to compute the differences.
	 */
	new(StateBasedDifferencesProvider differencesProvider, Set<VitruvDomain> domains) {
		this.changeFactory = VitruviusChangeFactory.instance
		this.domainRepository = new VitruvDomainRepositoryImpl(domains)
		this.differencesProvider = differencesProvider
	}

	private def checkNoProxies(Resource resource, String stateNotice) {
		val proxies = resource.referencedProxies
		checkArgument(proxies.empty, "%s '%s' should not contain proxies, but contains the following: %s", stateNotice,
			resource.URI, String.join(", ", proxies.map[toString]))
	}

	override getChangeSequenceBetween(Resource newState, Resource oldState, UuidResolver resolver) {
		checkArgument(resolver !== null, "UUID generator and resolver cannot be null!")
		checkArgument(oldState !== null && newState !== null, "old state or new state must not be null!")
		newState.checkNoProxies("new state")
		oldState.checkNoProxies("old state")
		val oldResourceSet = new ResourceSetImpl()
		val newResourceSet = new ResourceSetImpl()
		val currentStateCopy = ResourceUtil.createCopy(oldState, oldResourceSet)
		val newStateCopy = ResourceUtil.createCopy(newState, newResourceSet)
		val diffs = currentStateCopy.record(resolver) [
			if (oldState.URI != newState.URI) {
//				currentStateCopy.URI = newStateCopy.URI
			}
			compareStatesAndReplayChanges(newStateCopy, currentStateCopy)
		]
		return changeFactory.createCompositeChange(diffs)
	}

	override getChangeSequenceForCreated(Resource newState, UuidResolver resolver) {
		checkArgument(resolver !== null, "UUID generator and resolver cannot be null!")
		checkArgument(newState !== null, "new state must not be null!")
		newState.checkNoProxies("new state")
		// It is possible that root elements are automatically generated during resource creation (e.g., Java packages).
		// Thus, we create the resource and then monitor the re-insertion of the elements
		val resourceSet = new ResourceSetImpl().awareOfDomains(domainRepository)
		val newResource = resourceSet.createResource(newState.URI)
		newResource.contents.clear()
		val diffs = newResource.record(resolver) [
			newResource.contents += EcoreUtil.copyAll(newState.contents)
		]
		return changeFactory.createCompositeChange(diffs)
	}

	override getChangeSequenceForDeleted(Resource oldState, UuidResolver resolver) {
		checkArgument(resolver !== null, "UUID generator and resolver cannot be null!")
		checkArgument(oldState !== null, "old state must not be null!")
		oldState.checkNoProxies("old state")
		// Setup resolver and copy state:
		val copyResourceSet = new ResourceSetImpl()
		val currentStateCopy = ResourceUtil.createCopy(oldState, copyResourceSet)
		val diffs = currentStateCopy.record(resolver) [
			currentStateCopy.contents.clear()
		]
		return changeFactory.createCompositeChange(diffs)
	}

	private def <T extends Notifier> record(Resource resource, UuidResolver parentResolver, ()=>void function) {
		val uuidGeneratorAndResolver = createUuidGeneratorAndResolver(parentResolver, resource.resourceSet)
		try (val changeRecorder = new ChangeRecorder(uuidGeneratorAndResolver)) {
			changeRecorder.beginRecording
			changeRecorder.addToRecording(resource)
			function.apply()
			return changeRecorder.endRecording
		}
	}

	/**
	 * Compares states using EMFCompare and replays the changes to the current state.
	 */
	private def compareStatesAndReplayChanges(Notifier newState, Notifier currentState) {
	    val s1 = Stopwatch.createStarted()
		val changes = differencesProvider.getDifferences(newState, currentState)
		s1.stop()
		TimeMeasurement.shared.addStopwatchForKey(s1, "diff-provider")
		// Replay the EMF compare differences
		val mergerRegistry = IMerger.RegistryImpl.createStandaloneInstance()
		val merger = new BatchMerger(mergerRegistry)
		val s2 = Stopwatch.createStarted()
		merger.copyAllLeftToRight(changes, new BasicMonitor)
		s2.stop()
		TimeMeasurement.shared.addStopwatchForKey(s2, "replaying")
	}
}
