package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite.BasicSuiteTest
import tools.vitruv.applications.external.strategies.UMLDeleteReductionSimilarityBasedDifferencesProvider

class DeleteReductionSimilarityStrategyBasicSuiteTest extends BasicSuiteTest {
    override getDifferencesProvider() {
        return new UMLDeleteReductionSimilarityBasedDifferencesProvider
    }
}