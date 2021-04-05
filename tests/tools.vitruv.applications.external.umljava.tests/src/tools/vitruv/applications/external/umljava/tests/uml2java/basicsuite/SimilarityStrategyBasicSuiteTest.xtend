package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider

class SimilarityStrategyBasicSuiteTest extends BasicSuiteTest {
    override getDifferencesProvider() {
        return new SimilarityBasedDifferencesProvider
    }
}
