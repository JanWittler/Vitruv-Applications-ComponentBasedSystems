package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

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
        testModelInDirectory("ChangeMethodSignature")
    }

    @Test
    def void testCollapseHierarchy() {
        testModelInDirectory("CollapseHierarchy")
    }

    @Test
    def void testExtractSuperclass() {
        testModelInDirectory("ExtractSuperclass")
    }

    @Test
    def void testInlineClass() {
        testModelInDirectory("InlineClass")
    }

    @Test
    def void testExtractAssociatedClass() {
        testModelInDirectory("ExtractAssociatedClass")
    }

    @Test
    def void testRemoveAssociatedClass() {
        testModelInDirectory("RemoveAssociatedClass")
    }

    override extendJavaModel(Path preloadedModelPath, (Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider) {
        javaClassifierProvider.apply(#["basic", "config"], "Method").propagate [
            val method = methods.filter(ClassMethod).filter [ name == "toString" ].head
            // return this.name;
            val jStatement = StatementsFactory.eINSTANCE.createReturn
            val jReference = ReferencesFactory.eINSTANCE.createSelfReference
            jReference.self = LiteralsFactory.eINSTANCE.createThis
            val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
            fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "name" ].head
            jReference.next = EcoreUtil.copy(fieldReference)
            jStatement.returnValue = jReference
            method.statements.add(jStatement)
        ]

        javaClassifierProvider.apply(#["basic", "config"], "ProvidedInterface").propagate [
            val setter = methods.filter [ name == "setProvidedMethods" ].head
            EcoreUtil.delete(setter)
        ]

        javaClassifierProvider.apply(#["basic", "config"], "RequiredInterface").propagate [
            val setter = methods.filter [ name == "setRequiredMethods" ].head
            EcoreUtil.delete(setter)
        ]

        javaClassifierProvider.apply(#["basic", "config"], "EJB").propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]

            {   // printRequiredInterfaces();
                val printRequired = methods.filter(ClassMethod).filter [name == "printRequiredInterfaces" ].head
                val jRecursive = ReferencesFactory.eINSTANCE.createMethodCall
                jRecursive.target = printRequired
                val jExpression = ExpressionsFactory.eINSTANCE.createUnaryExpression
                jExpression.child = jRecursive
                val jStatement = StatementsFactory.eINSTANCE.createExpressionStatement
                jStatement.expression = jExpression
                printRequired.statements.add(jStatement)
            }

            {   // printProvidedInterfaces();
                val printProvided = methods.filter(ClassMethod).filter [ name == "printProvidedInterfaces" ].head
                val jRecursive = ReferencesFactory.eINSTANCE.createMethodCall
                jRecursive.target = printProvided
                val jExpression = ExpressionsFactory.eINSTANCE.createUnaryExpression
                jExpression.child = jRecursive
                val jStatement = StatementsFactory.eINSTANCE.createExpressionStatement
                jStatement.expression = jExpression
                printProvided.statements.add(jStatement)
            }
        ]

        javaClassifierProvider.apply(#["basic", "config"], "Config").propagate [
            for (methodName: #["getTimestamp", "setTimestamp", "getReconfigurable", "setReconfigurable", "setEjbs", "getEjbs"]) {
                val accessor = methods.filter [name == methodName ].head
                EcoreUtil.delete(accessor)
            }

            {   // return this.reconfigurable;
                val method = methods.filter(ClassMethod).filter [name == "isReconfigurable" ].head
                val jStatement = StatementsFactory.eINSTANCE.createReturn
                val jReference = ReferencesFactory.eINSTANCE.createSelfReference
                jReference.self = LiteralsFactory.eINSTANCE.createThis
                val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
                fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "reconfigurable" ].head
                jReference.next = EcoreUtil.copy(fieldReference)
                jStatement.returnValue = jReference
                method.statements.add(jStatement)
            }

            {   // return this.ejbs;
                val method = methods.filter(ClassMethod).filter [ name == "getEJBs" ].head
                val jStatement = StatementsFactory.eINSTANCE.createReturn
                val jReference = ReferencesFactory.eINSTANCE.createSelfReference
                jReference.self = LiteralsFactory.eINSTANCE.createThis
                val fieldReference = ReferencesFactory.eINSTANCE.createIdentifierReference
                fieldReference.target = containingConcreteClassifier.members.filter(Field).filter [ name == "ejbs" ].head
                jReference.next = EcoreUtil.copy(fieldReference)
                jStatement.returnValue = jReference
                method.statements.add(jStatement)
            }
        ]

        javaClassifierProvider.apply(#["basic", "data"], "CurrentUser").propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]

            val constructor = constructors.head
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

        javaClassifierProvider.apply(#["basic", "data"], "LegacyData").propagate [
            val setter = methods.filter [name == "setRequiredInterface" ].head
            EcoreUtil.delete(setter)
        ]

        javaClassifierProvider.apply(#["basic", "data"], "Metadata").propagate [
            val setter = methods.filter [name == "setEncoding" ].head
            EcoreUtil.delete(setter)
        ]
    }
}