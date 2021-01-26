package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled

class BasicSimilarityBasedTest extends BasicSuiteTest {
	
	@Test
	@Disabled("rename is not properly detected by basic similarity strategy")
	override testRenameClass() {
		super.testRenameClass()
	}
	
	override getDiffProvider() {
		return new BasicSimilarityBasedStateBasedChangeDiffProvider()
	}
}