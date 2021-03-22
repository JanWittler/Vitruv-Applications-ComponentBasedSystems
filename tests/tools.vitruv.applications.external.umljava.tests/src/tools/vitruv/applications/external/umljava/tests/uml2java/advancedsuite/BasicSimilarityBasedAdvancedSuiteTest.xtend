package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

import tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite.AdvancedSuiteTest
import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider

class BasicSimilarityBasedAdvancedSuiteTest extends AdvancedSuiteTest {
    override getDiffProvider() {
        return new BasicSimilarityBasedStateBasedChangeDiffProvider
    }
}