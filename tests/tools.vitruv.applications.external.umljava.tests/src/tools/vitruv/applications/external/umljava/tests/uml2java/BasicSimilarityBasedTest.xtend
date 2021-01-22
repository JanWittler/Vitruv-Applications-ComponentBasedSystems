package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider

class BasicSimilarityBasedTest extends BasicSuiteTest {
	override getDiffProvider() {
		return new BasicSimilarityBasedStateBasedChangeDiffProvider()
	}
}