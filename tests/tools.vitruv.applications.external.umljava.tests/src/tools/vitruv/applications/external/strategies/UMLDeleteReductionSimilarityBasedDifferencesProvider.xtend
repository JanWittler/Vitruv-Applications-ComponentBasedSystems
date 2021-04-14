package tools.vitruv.applications.external.strategies

import java.util.EnumSet
import org.eclipse.emf.ecore.EObject
import org.eclipse.uml2.uml.Association

/**
 * This strategy is targeted for the UML domain and contains custom object filtering for the delete reduction matching.
 * In particular, any associations or ancestors of associations are excluded from the custom post-processing.
 * This is necessary since EMFCompare creates incorrect matches for associations.
 */
class UMLDeleteReductionSimilarityBasedDifferencesProvider extends DeleteReductionSimilarityBasedDifferencesProvider {
    new() {
        super(defaultEObjectFilter)
    }

    new(EnumSet<Option> options) {
        super(options, defaultEObjectFilter)
    }

    private static def (EObject)=>boolean defaultEObjectFilter() {
        return [
            var eObject = it
            while (eObject !== null) {
                if (eObject instanceof Association) {
                    return false
                }
                eObject = eObject.eContainer
            }
            return true
        ]
    }
}