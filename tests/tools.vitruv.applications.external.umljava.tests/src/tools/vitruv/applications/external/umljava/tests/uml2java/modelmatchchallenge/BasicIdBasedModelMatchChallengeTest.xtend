package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.strategies.BasicStateBasedChangeDiffProvider

class BasicIdBasedModelMatchChallengeTest extends ModelMatchChallengeTest {
	override getDiffProvider() {
		return new BasicStateBasedChangeDiffProvider()
	}
}