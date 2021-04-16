package tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing

import tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing.SimilarityFailingConstructedTest
import tools.vitruv.applications.external.strategies.UMLDeleteReductionSimilarityBasedDifferencesProvider

class DeleteReductionSimilarityStrategySimilarityFailingConstructedTest extends SimilarityFailingConstructedTest {
    override getDifferencesProvider() {
        return new UMLDeleteReductionSimilarityBasedDifferencesProvider
    }
}