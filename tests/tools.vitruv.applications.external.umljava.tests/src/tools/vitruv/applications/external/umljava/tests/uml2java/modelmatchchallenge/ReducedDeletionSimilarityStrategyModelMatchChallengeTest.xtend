package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge.ModelMatchChallengeTest
import tools.vitruv.applications.external.strategies.ReducedDeletionSimilarityBasedDifferencesProvider

class ReducedDeletionSimilarityStrategyModelMatchChallengeTest extends ModelMatchChallengeTest {
    override getDifferencesProvider() {
        return new ReducedDeletionSimilarityBasedDifferencesProvider
    }
}