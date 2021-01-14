package tools.vitruv.applications.external.umljava.tests.uml2java

import org.junit.jupiter.api.Test
import tools.vitruv.external.applications.external.strategies.BasicStateBasedChangeDiffProvider

class ExampleTest extends DiffProvidingStateBasedChangeTest {
	override getDiffProvider() {
		return new BasicStateBasedChangeDiffProvider()
	}
	
	@Test
	def void firstTest() {
		val changedModelPath = resourcesDirectory().resolve("Renamed.uml")
		resolveChangedState(changedModelPath)
		printChanges()
		
		val expectedTargetModel = resourcesDirectory().resolve("expected_src")
		assertTargetModelEquals(expectedTargetModel)
	}
}