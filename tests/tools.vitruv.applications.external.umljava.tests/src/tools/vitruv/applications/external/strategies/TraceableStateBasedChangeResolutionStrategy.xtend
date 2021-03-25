package tools.vitruv.applications.external.strategies

import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import org.eclipse.emf.ecore.resource.Resource
import tools.vitruv.framework.uuid.UuidResolver
import tools.vitruv.framework.change.description.VitruviusChange
import org.eclipse.xtend.lib.annotations.Accessors

class TraceableStateBasedChangeResolutionStrategy implements StateBasedChangeResolutionStrategy {
    @Accessors(PUBLIC_SETTER, PUBLIC_GETTER) StateBasedChangeResolutionStrategy strategy
    VitruviusChange changeSequence

    override getChangeSequences(Resource newState, Resource currentState, UuidResolver resolver) {
        val changeSequence = strategy?.getChangeSequences(newState, currentState, resolver)
        this.changeSequence = changeSequence
        return changeSequence
    }

    def getChangeSequence() {
        if (changeSequence === null) {
            throw new NullPointerException("Accessing change sequence without generating one before")
        }
        return changeSequence
    }

    def reset() {
        changeSequence = null
    }
}
