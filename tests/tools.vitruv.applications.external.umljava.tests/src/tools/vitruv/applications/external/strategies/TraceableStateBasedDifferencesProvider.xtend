package tools.vitruv.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff
import org.eclipse.xtend.lib.annotations.Accessors

/** A difference provider to access the differences computed by the passed differences provider. Does not compute differences by itself. */
class TraceableStateBasedDifferencesProvider implements StateBasedDifferencesProvider {
    /** The differences provider used to compute differences. */
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var StateBasedDifferencesProvider differencesProvider
    @Accessors(PUBLIC_GETTER) var List<Diff> differences

    override getDifferences(Notifier newState, Notifier oldState) {
        differences = differencesProvider?.getDifferences(newState, oldState)
        return differences
    }

    def reset() {
        differences = null
    }
}
