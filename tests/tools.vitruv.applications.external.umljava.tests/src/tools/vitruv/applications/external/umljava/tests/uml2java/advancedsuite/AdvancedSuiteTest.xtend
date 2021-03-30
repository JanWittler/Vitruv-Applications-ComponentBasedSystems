package tools.vitruv.applications.external.umljava.tests.uml2java.advancedsuite

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.uml2.uml.Class
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

    override enrichJavaModel(Path preloadedModelPath, (List<String>, String)=>Class umlClassProvider) {
        val methodClass = umlClassProvider.apply(#["basic", "config"], "Method")
        getModifiableCorrespondingObject(methodClass, ConcreteClassifier).propagate [
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

        val ejbClass = umlClassProvider.apply(#["basic", "config"], "EJB")
        getModifiableCorrespondingObject(ejbClass, ConcreteClassifier).propagate [
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

        val configClass = umlClassProvider.apply(#["basic", "config"], "Config")
        getModifiableCorrespondingObject(configClass, ConcreteClassifier).propagate [
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

        val provInterfaceClass = umlClassProvider.apply(#["basic", "config"], "ProvidedInterface")
        getModifiableCorrespondingObject(provInterfaceClass, ConcreteClassifier).propagate [
            val setter = methods.filter [ name == "setProvidedMethods" ].head
            EcoreUtil.delete(setter)
        ]

        val reqInterfaceClass = umlClassProvider.apply(#["basic", "config"], "RequiredInterface")
        getModifiableCorrespondingObject(reqInterfaceClass, ConcreteClassifier).propagate [
            val setter = methods.filter [ name == "setRequiredMethods" ].head
            EcoreUtil.delete(setter)
        ]

        val currentUserClass = umlClassProvider.apply(#["basic", "data"], "CurrentUser")
        getModifiableCorrespondingObject(currentUserClass, ConcreteClassifier).propagate [
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

        val legacyDataClass = umlClassProvider.apply(#["basic", "data"], "LegacyData")
        getModifiableCorrespondingObject(legacyDataClass, ConcreteClassifier).propagate [
            val setter = methods.filter [name == "setRequiredInterface" ].head
            EcoreUtil.delete(setter)
        ]

        val metadataClass = umlClassProvider.apply(#["basic", "data"], "Metadata")
        getModifiableCorrespondingObject(metadataClass, ConcreteClassifier).propagate [
            val setter = methods.filter [name == "setEncoding" ].head
            EcoreUtil.delete(setter)
        ]
    }
}