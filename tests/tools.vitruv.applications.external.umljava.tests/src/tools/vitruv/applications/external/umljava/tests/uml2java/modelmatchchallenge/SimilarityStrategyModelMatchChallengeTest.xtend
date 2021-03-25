package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider

class SimilarityStrategyModelMatchChallengeTest extends ModelMatchChallengeTest {
    override getDifferencesProvider() {
        new SimilarityBasedDifferencesProvider
    }
}
