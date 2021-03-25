package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider

class SimilarityStrategyThesisSystemExampleTest extends ThesisSystemExampleTest {
    override getDifferencesProvider() {
        new SimilarityBasedDifferencesProvider
    }
}
