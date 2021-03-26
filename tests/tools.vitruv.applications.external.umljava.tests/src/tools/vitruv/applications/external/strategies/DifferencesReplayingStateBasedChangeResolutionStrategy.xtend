package tools.vitruv.applications.external.strategies

import java.util.Collections
import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.merge.BatchMerger
import org.eclipse.emf.compare.merge.IMerger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.TransactionalChange
import tools.vitruv.framework.change.description.VitruviusChangeFactory
import tools.vitruv.framework.change.recording.ChangeRecorder
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.uuid.UuidGeneratorAndResolver
import tools.vitruv.framework.uuid.UuidResolver

import static tools.vitruv.framework.uuid.UuidGeneratorAndResolverFactory.createUuidGeneratorAndResolver

/** A change resolution strategy that uses a @{link StateBasedDifferencesProvider} to compute the differences and replays them to convert them to a change sequence. */
class DifferencesReplayingStateBasedChangeResolutionStrategy implements StateBasedChangeResolutionStrategy {
    val StateBasedDifferencesProvider differencesProvider
    val VitruviusChangeFactory changeFactory

    /**
     * Initializes the strategy using the given differences provider.
     * @param differencesProvider The differences provider used to compute the differences.
     */
    new(StateBasedDifferencesProvider differencesProvider) {
        this.changeFactory = VitruviusChangeFactory.instance
        this.differencesProvider = differencesProvider
    }

    override getChangeSequenceBetween(Resource newState, Resource currentState, UuidResolver resolver) {
        return resolveChangeSequences(newState, currentState, resolver)
    }

    def private resolveChangeSequences(Resource newState, Resource currentState, UuidResolver resolver) {
        if (resolver === null) {
            throw new IllegalArgumentException("UUID generator and resolver cannot be null!")
        } else if (newState === null || currentState === null) {
            return changeFactory.createCompositeChange(Collections.emptyList)
        }
        // Setup resolver and copy state:
        val copyResourceSet = new ResourceSetImpl
        val uuidGeneratorAndResolver = createUuidGeneratorAndResolver(resolver, copyResourceSet)
        val currentStateCopy = ResourceUtil.createCopy(currentState, copyResourceSet)
        // Create change sequences:
        val diffs = compareStates(newState, currentStateCopy)
        val vitruvDiffs = replayChanges(diffs, currentStateCopy, uuidGeneratorAndResolver)
        currentStateCopy.save(emptyMap)
        return changeFactory.createCompositeChange(vitruvDiffs)
    }

    private def List<Diff> compareStates(Notifier newState, Notifier currentState) {
        return differencesProvider.getDifferences(newState, currentState)
    }

    /**
     * Replays a list of of differences and records the changes to receive Vitruv change sequences. 
     */
    private def List<? extends TransactionalChange> replayChanges(List<Diff> changesToReplay, Notifier currentState,
        UuidGeneratorAndResolver resolver) {
        // Setup recorder:
        try (val changeRecorder = new ChangeRecorder(resolver)) {
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
				
	override getChangeSequenceForCreated(Resource newState, UuidResolver resolver) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
				
	override getChangeSequenceForDeleted(Resource oldState, UuidResolver resolver) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
				
}
