package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider

class DefaultStrategyModelMatchChallengeTest extends ModelMatchChallengeTest {
    override getDifferencesProvider() {
        new DefaultStateBasedDifferencesProvider
    }
}
