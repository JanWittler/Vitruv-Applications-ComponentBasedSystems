package tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing

import java.nio.file.Path
import org.eclipse.emf.ecore.util.EcoreUtil
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

/**
 * Test cases explicitly constructed to show how the similarity-based strategy can fail.
 * The tests contain of minimal changes to show which changes result in failures in the similarity-based strategy.
 * 
 * @author Jan Wittler
 */
abstract class SimilarityFailingConstructedTest extends Uml2JavaStateBasedChangeTest {
    override resourcesDirectory() {
        super.resourcesDirectory.resolve("SimilarityFailing")
    }

    @Test
    /**
     * Renames a class and a property of the class.
     * The property's setter was deleted in the Java code.
     * The similarity-based strategy does not match the elements but recreates them, leading to a recreating of the setter.
     */
    def testRenameElement() {
        testModelInDirectory("RenameElement")
    }

    @Test
    /**
     * Renames a class and a property of the class. Additionally moves the class to another package
     * The property's setter was deleted in the Java code.
     * The similarity-based strategy does not match the elements but recreates them, leading to a recreating of the setter.
     */
    def testMoveRenamedElement() {
        testModelInDirectory("MoveRenamedElement")
    }

    override extendJavaModel(Path preloadedModelPath, (Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider) {
        javaClassifierProvider.apply(#["de"], "DomesticAnimal").propagate [
            val nicknameSetter = methods.filter [name == "setNickname" ].head
            EcoreUtil.delete(nicknameSetter)
        ]
    }
}