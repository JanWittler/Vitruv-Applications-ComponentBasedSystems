package tools.vitruv.applications.external.umljava.tests.uml2java.examplethesissystem

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider

class SimilarityStrategyExampleThesisSystemTest extends ExampleThesisSystemTest {
    override getDifferencesProvider() {
        new SimilarityBasedDifferencesProvider
    }
}
