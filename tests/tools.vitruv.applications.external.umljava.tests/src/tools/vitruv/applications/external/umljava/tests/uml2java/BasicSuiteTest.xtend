package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import org.junit.jupiter.api.Test
import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.emftext.language.java.literals.LiteralsFactory

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
	
	override enrichJavaModel() {
		resourceAt(testProjectFolder.resolve("src/com.example.first/Example.java")).record [
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