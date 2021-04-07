package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

import tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite.AdvancedSuiteTest
import tools.vitruv.applications.external.strategies.ReducedDeletionSimilarityBasedDifferencesProvider

class ReducedDeletionSimilarityStrategyAdvancedSuiteTest extends AdvancedSuiteTest {
    override getDifferencesProvider() {
        return new ReducedDeletionSimilarityBasedDifferencesProvider
    }
}