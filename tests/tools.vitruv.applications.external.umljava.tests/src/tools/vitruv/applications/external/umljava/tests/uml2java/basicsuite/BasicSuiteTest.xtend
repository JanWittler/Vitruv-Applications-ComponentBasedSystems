package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import java.nio.file.Path
import org.eclipse.emf.ecore.util.EcoreUtil
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.emftext.language.java.expressions.ExpressionsFactory
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.members.Field
import org.emftext.language.java.operators.OperatorsFactory
import org.emftext.language.java.references.ReferencesFactory
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

abstract class BasicSuiteTest extends Uml2JavaStateBasedChangeTest {
    @Test
    def testAddClass() {
        testModelInDirectory("AddClass")
    }

    @Test
    def testRemoveClass() {
        testModelInDirectory("RemoveClass")
    }

    @Test
    def testRenameClass() {
        testModelInDirectory("RenameClass")
    }

    @Test
    def testMoveClassEasy() {
        testModelInDirectory("MoveClassEasy")
    }

    @Test
    def testMoveClassHard() {
        testModelInDirectory("MoveClassHard")
    }

    @Test
    def testAddAttribute() {
        testModelInDirectory("AddAttribute")
    }

    @Test
    def testRemoveAttribute() {
        testModelInDirectory("RemoveAttribute")
    }

    @Test
    def testRenameAttribute() {
        testModelInDirectory("RenameAttribute")
    }

    @Test
    def testMoveAttribute() {
        testModelInDirectory("MoveAttribute")
    }

    @Test
    def testAddMethod() {
        testModelInDirectory("AddMethod")
    }

    @Test
    def testRemoveMethod() {
        testModelInDirectory("RemoveMethod")
    }

    @Test
    def testRenameMethod() {
        testModelInDirectory("RenameMethod")
    }

    @Test
    def testMoveMethod() {
        testModelInDirectory("MoveMethod")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("BasicSuite")
    }

    override extendJavaModel(Path preloadedModelPath, (Iterable<String>, String) => ConcreteClassifier javaClassifierProvider) { 
        javaClassifierProvider.apply(#["com.example.first"], "Example").propagate [
            val setName = methods.filter [ name == "setName" ].head
            EcoreUtil.delete(setName)

            val method = methods.filter(ClassMethod).filter [ name == "nameEquals"].head
            // return this.name == otherName;
            val jParamRef = ReferencesFactory.eINSTANCE.createIdentifierReference
            jParamRef.target = method.parameters.head

            val selfReference = ReferencesFactory.eINSTANCE.createSelfReference
            selfReference.self = LiteralsFactory.eINSTANCE.createThis
            val jField = containingConcreteClassifier.members.filter(Field).filter [ name == "name" ].head
            val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
            fieldReference.target = jField
            selfReference.next = fieldReference

            val jComparison = ExpressionsFactory.eINSTANCE.createEqualityExpression
            jComparison.children += selfReference
            jComparison.equalityOperators += OperatorsFactory.eINSTANCE.createEqual
            jComparison.children += jParamRef

            val jStatement = StatementsFactory.eINSTANCE.createReturn
            jStatement.returnValue = jComparison
            method.statements.add(jStatement)
        ]
    }
}
