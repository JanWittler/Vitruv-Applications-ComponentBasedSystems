package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.umljava.tests.uml2java.DiffProvidingStateBasedChangeTest
import org.junit.jupiter.api.Test

abstract class UML2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
	@Test
	def testRename() {
		testModels("Renamed")
	}
	
	def testModels(String directory) {
		val changedModelPath = resourcesDirectory().resolve(directory).resolve("Model.uml")
		resolveChangedState(changedModelPath)
		
		val expectedTargetModel = resourcesDirectory().resolve(directory).resolve("expected_src")
		assertTargetModelEquals(expectedTargetModel)
	}
}