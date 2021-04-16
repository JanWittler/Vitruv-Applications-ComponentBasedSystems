package tools.vitruv.applications.external.umljava.tests.uml2java.examplethesissystem

import tools.vitruv.applications.external.strategies.UMLDeleteReductionSimilarityBasedDifferencesProvider

class DeleteReductionSimilarityStrategyExampleThesisSystemTest extends ExampleThesisSystemTest {
    override getDifferencesProvider() {
        return new UMLDeleteReductionSimilarityBasedDifferencesProvider
    }
}