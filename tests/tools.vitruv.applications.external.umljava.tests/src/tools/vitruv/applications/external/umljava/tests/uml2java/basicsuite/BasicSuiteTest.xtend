package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import java.nio.file.Path
import java.util.List
import org.eclipse.uml2.uml.Class
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

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

    @Test
    def testRenameAttribute() {
        testModels("RenameAttribute")
    }

    @Test
    def testMoveAttribute() {
        testModels("MoveAttribute")
    }

    @Test
    def testAddMethod() {
        testModels("AddMethod")
    }

    @Test
    def testRemoveMethod() {
        testModels("RemoveMethod")
    }

    @Test
    def testRenameMethod() {
        testModels("RenameMethod")
    }

    @Test
    def testMoveMethod() {
        testModels("MoveMethod")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("BasicSuite")
    }

    override enrichJavaModel(Path preloadedModelPath, (List<String>, String) => Class umlClassProvider) {
        val umlClass = umlClassProvider.apply(#["com.example.first"], "Example")
        val umlOperation = umlClass.ownedOperations.filter [name == "nameEquals" ].head
        getModifiableCorrespondingObject(umlOperation, ClassMethod).propagate [
            val jStatement = StatementsFactory.eINSTANCE.createReturn()
            val jBool = LiteralsFactory.eINSTANCE.createBooleanLiteral()
            jBool.value = false
            jStatement.returnValue = jBool
            statements.add(jStatement)
        ]
    }
}
