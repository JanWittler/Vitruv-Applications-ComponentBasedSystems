package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.external.applications.external.strategies.BasicStateBasedChangeDiffProvider
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProjectManager

@ExtendWith(TestProjectManager, TestLogging)
class ExampleTest extends DiffProvidingStateBasedChangeTest {
	override getDiffProvider() {
		return new BasicStateBasedChangeDiffProvider()
	}
	
	@Test
	def void firstTest() {
		val changedModelPath = Path.of("testresources").resolve("Renamed.uml")
		resolveChangedState(changedModelPath)
		logChanges()
	}
}