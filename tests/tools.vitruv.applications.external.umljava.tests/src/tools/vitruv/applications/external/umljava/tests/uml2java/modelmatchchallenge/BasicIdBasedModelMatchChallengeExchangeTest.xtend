package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.strategies.BasicStateBasedChangeDiffProvider

class BasicIdBasedModelMatchChallengeExchangeTest extends ModelMatchChallengeExchangeTest {
	override getDiffProvider() {
		new BasicStateBasedChangeDiffProvider
	}
}