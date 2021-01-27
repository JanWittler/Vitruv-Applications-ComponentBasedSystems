package tools.vitruv.applications.external.umljava.tests.uml2java

import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.Test
import tools.vitruv.domains.java.util.JavaPersistenceHelper

abstract class BasicSuiteTest extends Uml2JavaStateBasedChangeTest {
	@Test
	def testAddClass() {
		testModels("AddClass")
	}
	
	@Test
	def testRemoveClass() {
		testModels("RemoveClass")
	}
	
	@Test
	def testRenameClass() {
		testModels("RenameClass")
	}
	
	@Test
	def testMoveClassEasy() {
		testModels("MoveClassEasy")
	}
	
	@Test
	def testMoveClassHard() {
		testModels("MoveClassHard")
	}
	
	@Test
	def testAddAttribute() {
		testModels("AddAttribute")
	}
	
	@Test
	def testRemoveAttribute() {
		testModels("RemoveAttribute")
	}
	
	override resourcesDirectory() {
		super.resourcesDirectory.resolve("BasicSuite")
	}
	
	override enrichJavaModel() {
		val javaFilePath = testProjectFolder
			.resolve(JavaPersistenceHelper.buildJavaFilePath("Example.java", #["com.example.first"]))
		resourceAt(javaFilePath).record [
			val jCompilationUnit = contents.head as CompilationUnit
			val jClass = jCompilationUnit.classifiers.head
			val jClassMethod = jClass.members.get(3) as ClassMethod
			
			val jStatement = StatementsFactory.eINSTANCE.createReturn()
			val jBool = LiteralsFactory.eINSTANCE.createBooleanLiteral()
			jBool.value = false
			jStatement.returnValue = jBool
			jClassMethod.statements.add(jStatement)
		]
		propagate
	}
}