package tools.vitruv.applications.external.strategies

import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.scope.DefaultComparisonScope

/** The default differences provider. 
 * Uses EMF Compare without any custom settings.
 * This means that ID-based matching is used if IDs are present.
 * Otherwise a similarity-based matching is performed.
 */
class DefaultStateBasedDifferencesProvider implements StateBasedDifferencesProvider {
    override getDifferences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)
        val comparison = EMFCompare.builder.build.compare(scope)
        return comparison.differences
    }
}
