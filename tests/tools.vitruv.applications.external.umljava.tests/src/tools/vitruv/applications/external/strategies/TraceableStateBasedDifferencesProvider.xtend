package tools.vitruv.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff
import org.eclipse.xtend.lib.annotations.Accessors

class TraceableStateBasedDifferencesProvider implements StateBasedDifferencesProvider {
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var StateBasedDifferencesProvider differencesProvider
    var List<Diff> differences

    override getDifferences(Notifier newState, Notifier oldState) {
        differences = differencesProvider?.getDifferences(newState, oldState)
        return differences
    }

    def getDifferences() {
        if (differences === null) {
            throw new NullPointerException("Accessing differences without generating some before")
        }
        return differences
    }

    def reset() {
        differences = null
    }
}
