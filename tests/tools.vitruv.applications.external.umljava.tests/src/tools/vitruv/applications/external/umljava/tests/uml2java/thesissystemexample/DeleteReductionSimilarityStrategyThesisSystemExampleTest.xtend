package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample.ThesisSystemExampleTest
import tools.vitruv.applications.external.strategies.UMLDeleteReductionSimilarityBasedDifferencesProvider

class DeleteReductionSimilarityStrategyThesisSystemExampleTest extends ThesisSystemExampleTest {
    override getDifferencesProvider() {
        return new UMLDeleteReductionSimilarityBasedDifferencesProvider
    }
}