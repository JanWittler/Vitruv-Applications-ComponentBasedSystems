package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategyBasicSuiteTest extends BasicSuiteTest {
    override getDifferencesProvider() {
        return new DefaultStateBasedDifferencesProvider
    }
}
