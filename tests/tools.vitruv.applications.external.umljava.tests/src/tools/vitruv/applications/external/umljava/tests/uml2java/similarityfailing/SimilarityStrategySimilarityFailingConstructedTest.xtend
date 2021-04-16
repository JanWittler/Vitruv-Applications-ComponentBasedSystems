package tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider

class SimilarityStrategySimilarityFailingConstructedTest extends SimilarityFailingConstructedTest {
    override getDifferencesProvider() {
        new SimilarityBasedDifferencesProvider
    }
}