package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge.ModelMatchChallengeTest
import tools.vitruv.applications.external.strategies.DeleteReductionSimilarityBasedDifferencesProvider

class DeleteReductionSimilarityStrategyModelMatchChallengeTest extends ModelMatchChallengeTest {
    override getDifferencesProvider() {
        return new DeleteReductionSimilarityBasedDifferencesProvider
    }
}