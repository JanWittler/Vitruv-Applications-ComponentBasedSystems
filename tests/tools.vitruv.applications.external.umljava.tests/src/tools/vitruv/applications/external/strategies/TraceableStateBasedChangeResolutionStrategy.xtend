package tools.vitruv.applications.external.strategies

import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import org.eclipse.emf.ecore.resource.Resource
import tools.vitruv.framework.uuid.UuidResolver
import tools.vitruv.framework.change.description.VitruviusChange
import org.eclipse.xtend.lib.annotations.Accessors

/** A change resolution strategy to access the change sequence computed by the passed strategy. Does not compute change sequences by itself. */
class TraceableStateBasedChangeResolutionStrategy implements StateBasedChangeResolutionStrategy {
    /** The strategy used to compute the change sequence. */
    @Accessors(PUBLIC_SETTER, PUBLIC_GETTER) StateBasedChangeResolutionStrategy strategy
    @Accessors(PUBLIC_GETTER) VitruviusChange changeSequence

    override getChangeSequenceBetween(Resource newState, Resource currentState, UuidResolver resolver) {
        val changeSequence = strategy?.getChangeSequenceBetween(newState, currentState, resolver)
        this.changeSequence = changeSequence
        return changeSequence
    }

    def reset() {
        changeSequence = null
    }

    override getChangeSequenceForCreated(Resource newState, UuidResolver resolver) {
        val changeSequence = strategy?.getChangeSequenceForCreated(newState, resolver)
        this.changeSequence = changeSequence
        return changeSequence
    }

    override getChangeSequenceForDeleted(Resource oldState, UuidResolver resolver) {
        val changeSequence = strategy?.getChangeSequenceForDeleted(oldState, resolver)
        this.changeSequence = changeSequence
        return changeSequence
    }

}
