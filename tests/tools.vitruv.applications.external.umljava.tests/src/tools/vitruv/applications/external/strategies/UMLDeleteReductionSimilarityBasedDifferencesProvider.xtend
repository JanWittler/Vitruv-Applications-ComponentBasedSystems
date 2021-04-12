package tools.vitruv.applications.external.strategies

import tools.vitruv.applications.external.strategies.DeleteReductionSimilarityBasedDifferencesProvider
import java.util.EnumSet

class UMLDeleteReductionSimilarityBasedDifferencesProvider extends DeleteReductionSimilarityBasedDifferencesProvider {
    new() {
        super([eClass.name != "Association"])
    }

    new(EnumSet<Option> options) {
        super(options, [eClass.name != "Association"])
    }
}