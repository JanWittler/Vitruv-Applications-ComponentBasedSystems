package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider

class BasicSimilarityBasedTest extends Uml2JavaStateBasedChangeTest {
	override getDiffProvider() {
		return new BasicSimilarityBasedStateBasedChangeDiffProvider()
	}
}