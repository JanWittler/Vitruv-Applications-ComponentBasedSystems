package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

/**
 * A test suite mimicking the tests described in 
 * <a href="https://doi.org/10.1007/s40568-013-0061-x">Model Matching Challenge: Benchmarks for Ecore and BPMN Diagrams</a>.
 * @author Jan Wittler
 */
abstract class ModelMatchChallengeTest extends Uml2JavaStateBasedChangeTest {
	@Test
	def void testMove() {
		testModels("MoveElement")
	}
	
	@Test
	def void testMoveRenamed() {
		testModels("MoveRenamedElement")
	}
	
	override resourcesDirectory() {
		super.resourcesDirectory.resolve("ModelMatchChallenge")
	}
	
	override enrichJavaModel() {
	}
}