package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategyThesisSystemExampleTest extends ThesisSystemExampleTest {
    override getDifferencesProvider() {
        new DefaultStateBasedDifferencesProvider
    }
}
