package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider
import tools.vitruv.applications.external.umljava.tests.uml2java.generated.SmallGeneratedTest

class SimilarityStrategySmallGeneratedTest extends SmallGeneratedTest {
    override getDifferencesProvider() {
        return new SimilarityBasedDifferencesProvider
    }
}
