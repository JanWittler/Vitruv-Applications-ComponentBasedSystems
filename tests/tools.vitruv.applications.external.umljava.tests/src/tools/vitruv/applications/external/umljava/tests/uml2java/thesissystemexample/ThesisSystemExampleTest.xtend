package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.uml2.uml.Class
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

/**
 * A test suite mimicking the test described in 
 * <a href="http://ceur-ws.org/Vol-1706/paper6.pdf">Semantic-based Model Matching with EMFCompare</a>.
 * @author Jan Wittler
 */
abstract class ThesisSystemExampleTest extends Uml2JavaStateBasedChangeTest {
    @Test
    def void testThesisSystemExample() {
        testModelInDirectory("Test1")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("ThesisSystemExample")
    }

    override preloadModel(Path path) {
        // select ArrayList for all to-many associations
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        super.preloadModel(path)
    }

    override enrichJavaModel(Path preloadedModelPath, (List<String>, String) => Class umlClassProvider) {
        val departmentClass = umlClassProvider.apply(#["root"], "Department")
        getModifiableCorrespondingObject(departmentClass, ConcreteClassifier).propagate [
            val idSetter = methods.filter [ name == "setId" ].head
            EcoreUtil.delete(idSetter)
        ]

        val studentClass = umlClassProvider.apply(#["root"], "Student")
        getModifiableCorrespondingObject(studentClass, ConcreteClassifier).propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]
        ]

        val teacherClass = umlClassProvider.apply(#["root"], "TeachingStaffMember")
        getModifiableCorrespondingObject(teacherClass, ConcreteClassifier).propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]
        ]

        val thesisClass = umlClassProvider.apply(#["root"], "Thesis")
        getModifiableCorrespondingObject(thesisClass, ConcreteClassifier).propagate [
            val idSetter = methods.filter [ name == "setId" ].head
            EcoreUtil.delete(idSetter)

            val gradeSetter = methods.filter [ name == "setGrade" ].head
            EcoreUtil.delete(gradeSetter)
        ]

        val thesisSystemClass = umlClassProvider.apply(#["root"], "ThesisSystem")
        getModifiableCorrespondingObject(thesisSystemClass, ConcreteClassifier).propagate [
            val departmentsSetter = methods.filter [ name == "setDepartments" ].head
            EcoreUtil.delete(departmentsSetter)
        ]
    }
}
