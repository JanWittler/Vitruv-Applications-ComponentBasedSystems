package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite.BasicSuiteTest
import tools.vitruv.applications.external.strategies.ReducedDeletionSimilarityBasedDifferencesProvider

class ReducedDelectionSimilarityStrategyBasicSuiteTest extends BasicSuiteTest {
    override getDifferencesProvider() {
        return new ReducedDeletionSimilarityBasedDifferencesProvider
    }
}