package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider

class BasicSimilarityBasedModelMatchChallengeTest extends ModelMatchChallengeTest {
    override getDiffProvider() {
        new BasicSimilarityBasedStateBasedChangeDiffProvider
    }
}
