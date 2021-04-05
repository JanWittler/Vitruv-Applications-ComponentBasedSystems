package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import java.nio.file.Path
import org.eclipse.emf.ecore.util.EcoreUtil
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

    override extendJavaModel(Path preloadedModelPath, (Iterable<String>, String) => ConcreteClassifier javaClassifierProvider) {
        javaClassifierProvider.apply(#["root"], "Department").propagate [
            val idSetter = methods.filter [ name == "setId" ].head
            EcoreUtil.delete(idSetter)
        ]

        javaClassifierProvider.apply(#["root"], "Student").propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]
        ]

        javaClassifierProvider.apply(#["root"], "TeachingStaffMember").propagate [
            val setters = methods.filter [ name.startsWith("set") ]
            setters.forEach [ EcoreUtil.delete(it) ]
        ]

        javaClassifierProvider.apply(#["root"], "Thesis").propagate [
            val idSetter = methods.filter [ name == "setId" ].head
            EcoreUtil.delete(idSetter)

            val gradeSetter = methods.filter [ name == "setGrade" ].head
            EcoreUtil.delete(gradeSetter)
        ]

        javaClassifierProvider.apply(#["root"], "ThesisSystem").propagate [
            val departmentsSetter = methods.filter [ name == "setDepartments" ].head
            EcoreUtil.delete(departmentsSetter)
        ]
    }
}
