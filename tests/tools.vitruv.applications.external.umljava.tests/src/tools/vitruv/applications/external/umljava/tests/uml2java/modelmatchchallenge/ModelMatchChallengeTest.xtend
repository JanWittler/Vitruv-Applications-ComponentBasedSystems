package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.uml2.uml.Class
import org.emftext.language.java.members.ClassMethod
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

/**
 * A test suite mimicking the tests described in 
 * <a href="https://doi.org/10.1007/s40568-013-0061-x">Model Matching Challenge: Benchmarks for Ecore and BPMN Diagrams</a>.
 * @author Jan Wittler
 */
abstract class ModelMatchChallengeTest extends Uml2JavaStateBasedChangeTest {
    @Test
    def testMove() {
        testModels("MoveElement")
    }

    @Test
    def testRename() {
        testModels("RenameElement")
    }

    @Test
    def testMoveRenamed() {
        testModels("MoveRenamedElement")
    }

    @Tag(CUSTOM_INITIAL_MODEL_TAG)
    @Test
    def testExchangeElements() {
        preloadModel(resourcesDirectory.resolve("tests/ExchangeElements/Base/Base.uml"))

        testModels("ExchangeElements")
    }

    @Test
    def testUpdateReferenceTarget() {
        testModels("UpdateReferenceTarget")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("ModelMatchChallenge")
    }

    override enrichJavaModel(Path preloadedModelPath, (List<String>, String) => Class umlClassProvider) {
        if (preloadedModelPath.contains(Path.of("ExchangeElements"))) {
            enrichExchangeElementsJavaModel(umlClassProvider)
        } else {
            enrichDefaultJavaModel(umlClassProvider)
        }
    }

    private def enrichDefaultJavaModel((List<String>, String) => Class umlClassProvider) {
        val umlClass = umlClassProvider.apply(#["de"], "DomesticAnimal")
        val umlProperty = umlClass.ownedAttributes.filter [ name == "species" ].head
        getModifiableCorrespondingObject(umlProperty, ClassMethod, "setter").propagate [
            EcoreUtil.delete(it)
        ]
    }

    private def enrichExchangeElementsJavaModel((List<String>, String) => Class umlClassProvider) {
        val umlClass = umlClassProvider.apply(#["de", "shop"], "DomesticAnimal")
        val umlProperty = umlClass.ownedAttributes.filter [ name == "species" ].head
        getModifiableCorrespondingObject(umlProperty, ClassMethod, "setter").propagate [
            name = "changeSpecies"
        ]

        val umlClass2 = umlClassProvider.apply(#["de", "core"], "DomesticAnimalNew")
        val umlProperty2 = umlClass2.ownedAttributes.filter [ name == "species" ].head
        getModifiableCorrespondingObject(umlProperty2, ClassMethod, "setter").propagate [
            name = "adjustSpecies"
        ]
    }
}
