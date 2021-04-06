package tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategySimilarityFailingConstructedTest extends SimilarityFailingConstructedTest {
    override getDifferencesProvider() {
        new DefaultStateBasedDifferencesProvider
    }
}