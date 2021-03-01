package tools.vitruv.applications.external.strategies

import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.scope.DefaultComparisonScope

class BasicStateBasedChangeDiffProvider implements StateBasedChangeDiffProvider {
    override getChangeSequences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)
        val comparison = EMFCompare.builder.build.compare(scope)
        return comparison.differences
    }
}
