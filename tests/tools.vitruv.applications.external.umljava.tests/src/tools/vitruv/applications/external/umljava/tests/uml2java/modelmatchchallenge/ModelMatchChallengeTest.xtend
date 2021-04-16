package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import java.nio.file.Path
import org.eclipse.emf.ecore.util.EcoreUtil
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest

/**
 * A test suite mimicking the tests described in 
 * <a href="https://doi.org/10.1007/s40568-013-0061-x">Model Matching Challenge: Benchmarks for Ecore and BPMN Diagrams</a>.
 * @author Jan Wittler
 */
abstract class ModelMatchChallengeTest extends Uml2JavaStateBasedChangeTest {
    @ParameterizedTest(name='{0}')
    @ValueSource(strings = #["Model", "Model_noAssociations"])
    def testMove(String modelName) {
        this.modelName = modelName
        testModelInDirectory("MoveElement")
    }

    @ParameterizedTest(name='{0}')
    @ValueSource(strings = #["Model", "Model_noAssociations"])
    def testRename(String modelName) {
        this.modelName = modelName
        testModelInDirectory("RenameElement")
    }

    @ParameterizedTest(name='{0}')
    @ValueSource(strings = #["Model", "Model_noAssociations"])
    def testMoveRenamed(String modelName) {
        this.modelName = modelName
        testModelInDirectory("MoveRenamedElement")
    }

    @Test
    def testExchangeElements() {
        testModelInDirectory("ExchangeElements")
    }

    @ParameterizedTest(name='{0}')
    @ValueSource(strings = #["Model", "Model_noAssociations"])
    def testUpdateReferenceTarget(String modelName) {
        this.modelName = modelName
        testModelInDirectory("UpdateReferenceTarget")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("ModelMatchChallenge")
    }

    override initialModelPath(TestInfo testInfo) {
        if (testInfo.displayName == "testExchangeElements()") {
            return resourcesDirectory.resolve("tests/ExchangeElements/Base/Model.uml")
        }
        return super.initialModelPath(testInfo)
    }

    override extendJavaModel(Path preloadedModelPath, (Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider) {
        if (preloadedModelPath.contains(Path.of("ExchangeElements"))) {
            extendExchangeElementsJavaModel(javaClassifierProvider)
        } else {
            extendDefaultJavaModel(javaClassifierProvider)
        }
    }

    private def extendDefaultJavaModel((Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider) {
        javaClassifierProvider.apply(#["de"], "DomesticAnimal").propagate [
            val speciesSetter = methods.filter [name == "setSpecies" ].head
            EcoreUtil.delete(speciesSetter)
        ]
    }

    private def extendExchangeElementsJavaModel((Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider) {
        javaClassifierProvider.apply(#["de", "shop"], "DomesticAnimal").propagate [
            val speciesSetter = methods.filter [ name == "setSpecies"].head
            EcoreUtil.delete(speciesSetter)
        ]

        javaClassifierProvider.apply(#["de", "core"], "DomesticAnimalNew").propagate [
            val nicknameSetter = methods.filter [name == "setNickname" ].head
            EcoreUtil.delete(nicknameSetter)
        ]
    }
}
