package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import org.emftext.language.java.containers.CompilationUnit
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import tools.vitruv.domains.java.util.JavaPersistenceHelper

/**
 * A test suite mimicking the tests described in 
 * <a href="https://doi.org/10.1007/s40568-013-0061-x">Model Matching Challenge: Benchmarks for Ecore and BPMN Diagrams</a>.
 * @author Jan Wittler
 */
abstract class ModelMatchChallengeTest extends Uml2JavaStateBasedChangeTest {
	@Test
	def testMove() {
		testModels("MoveElement")
	}
	
	@Test
	def testRename() {
		testModels("RenameElement")
	}
	
	@Test
	def testMoveRenamed() {
		testModels("MoveRenamedElement")
	}
	
	@Test
	def testUpdateReferenceTarget() {
		testModels("UpdateReferenceTarget")
	}
	
	override resourcesDirectory() {
		super.resourcesDirectory.resolve("ModelMatchChallenge")
	}
	
	override enrichJavaModel() {
		val javaFilePath = testProjectFolder
			.resolve(JavaPersistenceHelper.buildJavaFilePath("DomesticAnimal.java", #["de"]))
		resourceAt(javaFilePath).record [
			val jCompilationUnit = contents.head as CompilationUnit
			val jClass = jCompilationUnit.classifiers.head
			val jClassMethod = jClass.members.filter [ name == "setSpecies" ].head
			//TODO: the preferred update of simply removing the setter is currently not possible 
			// as this triggers a crash in the UUID resolver
			jClassMethod.name = "changeSpecies"
		]
		propagate
	}
}