package tools.vitruv.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff
import org.eclipse.xtend.lib.annotations.Accessors

class StateBasedChangeDiffProviderStorage implements StateBasedChangeDiffProvider {
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) var StateBasedChangeDiffProvider diffProvider
    var List<Diff> diffs

    override getChangeSequences(Notifier newState, Notifier oldState) {
        diffs = diffProvider?.getChangeSequences(newState, oldState)
        return diffs
    }

    def getDiffs() {
        if (diffs === null) {
            throw new NullPointerException("Accessing diffs without generating some before")
        }
        return diffs
    }

    def reset() {
        diffs = null
    }
}
