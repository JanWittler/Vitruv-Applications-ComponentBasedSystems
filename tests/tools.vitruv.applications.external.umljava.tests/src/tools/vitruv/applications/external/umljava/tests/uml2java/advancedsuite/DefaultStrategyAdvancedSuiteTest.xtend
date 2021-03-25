package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

import tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite.AdvancedSuiteTest
import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategyAdvancedSuiteTest extends AdvancedSuiteTest {
    override getDifferencesProvider() {
        return new DefaultStateBasedDifferencesProvider
    }
}