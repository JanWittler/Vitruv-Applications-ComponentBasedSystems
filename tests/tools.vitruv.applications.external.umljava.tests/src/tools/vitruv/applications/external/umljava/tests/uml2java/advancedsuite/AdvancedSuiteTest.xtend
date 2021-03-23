package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.uml2.uml.Class
import org.emftext.language.java.expressions.ExpressionsFactory
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.members.Constructor
import org.emftext.language.java.members.Field
import org.emftext.language.java.operators.OperatorsFactory
import org.emftext.language.java.references.ReferencesFactory
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

abstract class AdvancedSuiteTest extends Uml2JavaStateBasedChangeTest {
    override resourcesDirectory() {
        super.resourcesDirectory.resolve("AdvancedSuite")
    }

    override preloadModel(Path path) {
        // select ArrayList for all to-many associations
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        super.preloadModel(path)
    }

    @Test
    def void changeMethodSignature() {
        testModels("ChangeMethodSignature")
    }

    @Test
    def void testCollapseHierarchy() {
        testModels("CollapseHierarchy")
    }

    @Test
    def void testExtractSuperclass() {
        testModels("ExtractSuperclass")
    }

    @Test
    def void testInlineClass() {
        testModels("InlineClass")
    }

    @Test
    def void testExtractAssociatedClass() {
        testModels("ExtractAssociatedClass")
    }

    @Test
    def void testRemoveAssociatedClass() {
        testModels("RemoveAssociatedClass")
    }

    override enrichJavaModel(Path preloadedModelPath, (List<String>, String)=>Class umlClassProvider) {
        val methodClass = umlClassProvider.apply(#["basic", "config"], "Method")
        val methodOperation = methodClass.ownedOperations.filter [ name == "toString" ].head
        getModifiableCorrespondingObject(methodOperation, ClassMethod).propagate [
            // return this.name;
            val jStatement = StatementsFactory.eINSTANCE.createReturn
            val jReference = ReferencesFactory.eINSTANCE.createSelfReference
            jReference.self = LiteralsFactory.eINSTANCE.createThis
            val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
            fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "name" ].head
            jReference.next = EcoreUtil.copy(fieldReference)
            jStatement.returnValue = jReference
            statements.add(jStatement)
        ]

        val ejbClass = umlClassProvider.apply(#["basic", "config"], "EJB")
        val printRequiredOperation = ejbClass.ownedOperations.filter [ name == "printRequiredInterfaces"].head
        getModifiableCorrespondingObject(printRequiredOperation, ClassMethod).propagate [
            // printRequiredInterfaces();
            val jRecursive = ReferencesFactory.eINSTANCE.createMethodCall
            jRecursive.target = it
            val jExpression = ExpressionsFactory.eINSTANCE.createUnaryExpression
            jExpression.child = jRecursive
            val jStatement = StatementsFactory.eINSTANCE.createExpressionStatement
            jStatement.expression = jExpression
            statements.add(jStatement)
        ]

        val printProvidedOperation = ejbClass.ownedOperations.filter [ name == "printProvidedInterfaces"].head
        getModifiableCorrespondingObject(printProvidedOperation, ClassMethod).propagate [
            // printProvidedInterfaces();
            val jRecursive = ReferencesFactory.eINSTANCE.createMethodCall
            jRecursive.target = it
            val jExpression = ExpressionsFactory.eINSTANCE.createUnaryExpression
            jExpression.child = jRecursive
            val jStatement = StatementsFactory.eINSTANCE.createExpressionStatement
            jStatement.expression = jExpression
            statements.add(jStatement)
        ]

        val configClass = umlClassProvider.apply(#["basic", "config"], "Config")
        val reconfOperation = configClass.ownedOperations.filter [ name == "isReconfigurable" ].head
        getModifiableCorrespondingObject(reconfOperation, ClassMethod).propagate [
            // return this.reconfigurable;
            val jStatement = StatementsFactory.eINSTANCE.createReturn
            val jReference = ReferencesFactory.eINSTANCE.createSelfReference
            jReference.self = LiteralsFactory.eINSTANCE.createThis
            val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
            fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "reconfigurable" ].head
            jReference.next = EcoreUtil.copy(fieldReference)
            jStatement.returnValue = jReference
            statements.add(jStatement)
        ]

        val getEJBsOperations = configClass.ownedOperations.filter [ name == "getEJBs" ].head
        getModifiableCorrespondingObject(getEJBsOperations, ClassMethod).propagate [
            // return this.ejbs;
            val jStatement = StatementsFactory.eINSTANCE.createReturn
            val jReference = ReferencesFactory.eINSTANCE.createSelfReference
            jReference.self = LiteralsFactory.eINSTANCE.createThis
            val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
            fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "ejbs" ].head
            jReference.next = EcoreUtil.copy(fieldReference)
            jStatement.returnValue = jReference
            statements.add(jStatement)
        ]

        val currentUserClass = umlClassProvider.apply(#["basic", "data"], "CurrentUser")
        val currentUserConstructor = currentUserClass.ownedOperations.filter [ name == "CurrentUser" ].head
        getModifiableCorrespondingObject(currentUserConstructor, Constructor).propagate [ constructor |
            // this.<paramName> = <paramName>;
            constructor.parameters.forEach [ parameter |
                val jParamRef = ReferencesFactory.eINSTANCE.createIdentifierReference
                jParamRef.target = parameter

                val selfReference = ReferencesFactory.eINSTANCE.createSelfReference
                selfReference.self = LiteralsFactory.eINSTANCE.createThis
                val jField = constructor.containingConcreteClassifier.members.filter(Field).filter [ name == parameter.name ].head
                val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
                fieldReference.target = jField
                selfReference.next = fieldReference

                val jAssignment = ExpressionsFactory.eINSTANCE.createAssignmentExpression
                jAssignment.child = selfReference
                jAssignment.assignmentOperator = OperatorsFactory.eINSTANCE.createAssignment
                jAssignment.value = jParamRef

                val jStatement = StatementsFactory.eINSTANCE.createExpressionStatement
                jStatement.expression = jAssignment
                constructor.statements.add(jStatement)
            ]
        ]
    }
}