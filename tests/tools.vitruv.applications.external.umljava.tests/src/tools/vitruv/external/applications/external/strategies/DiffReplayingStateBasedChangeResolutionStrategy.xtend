package tools.vitruv.external.applications.external.strategies

import java.util.Collections
import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.merge.BatchMerger
import org.eclipse.emf.compare.merge.IMerger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.TransactionalChange
import tools.vitruv.framework.change.description.VitruviusChangeFactory
import tools.vitruv.framework.change.recording.AtomicEmfChangeRecorder
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.uuid.UuidGeneratorAndResolver
import tools.vitruv.framework.uuid.UuidGeneratorAndResolverImpl

class DiffReplayingStateBasedChangeResolutionStrategy implements StateBasedChangeResolutionStrategy {
	val StateBasedChangeDiffProvider diffProvider
	val VitruviusChangeFactory changeFactory

	new(StateBasedChangeDiffProvider diffProvider) {
		this.changeFactory = VitruviusChangeFactory.instance
		this.diffProvider = diffProvider
	}

	override getChangeSequences(Resource newState, Resource currentState, UuidGeneratorAndResolver resolver) {
		return resolveChangeSequences(newState, currentState, resolver)
	}

	override getChangeSequences(EObject newState, EObject currentState, UuidGeneratorAndResolver resolver) {
		return resolveChangeSequences(newState?.eResource, currentState?.eResource, resolver)
	}

	def private resolveChangeSequences(Resource newState, Resource currentState, UuidGeneratorAndResolver resolver) {
		if (resolver === null) {
			throw new IllegalArgumentException("UUID generator and resolver cannot be null!")
		} else if (newState === null || currentState === null) {
			return changeFactory.createCompositeChange(Collections.emptyList)
		}
		// Setup resolver and copy state:
		val uuidGeneratorAndResolver = new UuidGeneratorAndResolverImpl(resolver, resolver.resourceSet, true)
		val currentStateCopy = ResourceUtil.copy(currentState)
		// Create change sequences:
		val diffs = compareStates(newState, currentStateCopy)
		val vitruvDiffs = replayChanges(diffs, currentStateCopy, uuidGeneratorAndResolver)
		currentStateCopy.save(emptyMap)
		return changeFactory.createCompositeChange(vitruvDiffs)
	}

	/**
	 * Compares states using EMFCompare and returns a list of all differences.
	 */
	private def List<Diff> compareStates(Notifier newState, Notifier currentState) {
		return diffProvider.getChangeSequences(newState, currentState)
	}

	/**
	 * Replays a list of of EMFCompare differences and records the changes to receive Vitruv change sequences. 
	 */
	private def List<TransactionalChange> replayChanges(List<Diff> changesToReplay, Notifier currentState, UuidGeneratorAndResolver resolver) {
		// Setup recorder:
		val changeRecorder = new AtomicEmfChangeRecorder(resolver)
		changeRecorder.addToRecording(currentState)
		changeRecorder.beginRecording
		// replay the EMF compare diffs:
		val mergerRegistry = IMerger.RegistryImpl.createStandaloneInstance()
		val merger = new BatchMerger(mergerRegistry)
		merger.copyAllLeftToRight(changesToReplay, new BasicMonitor)
		// Finish recording:
		changeRecorder.endRecording
		return changeRecorder.changes
	}
}