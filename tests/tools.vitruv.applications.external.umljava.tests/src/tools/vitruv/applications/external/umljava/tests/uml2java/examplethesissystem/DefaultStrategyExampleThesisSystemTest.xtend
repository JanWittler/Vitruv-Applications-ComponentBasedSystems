package tools.vitruv.applications.external.umljava.tests.uml2java.examplethesissystem

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategyExampleThesisSystemTest extends ExampleThesisSystemTest {
    override getDifferencesProvider() {
        new DefaultStateBasedDifferencesProvider
    }
}
