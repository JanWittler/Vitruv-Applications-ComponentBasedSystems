package tools.vitruv.applications.external.umljava.tests.uml2java.similarityfailing

import java.nio.file.Path
import org.eclipse.emf.ecore.util.EcoreUtil
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

abstract class SimilarityFailingConstructedTest extends Uml2JavaStateBasedChangeTest {
    override resourcesDirectory() {
        super.resourcesDirectory.resolve("SimilarityFailing")
    }

    @Test
    def testRenameElement() {
        testModelInDirectory("RenameElement")
    }

    @Test
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