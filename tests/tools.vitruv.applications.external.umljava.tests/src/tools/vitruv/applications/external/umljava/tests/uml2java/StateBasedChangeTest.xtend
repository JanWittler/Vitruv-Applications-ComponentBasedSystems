package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.io.FileWriter
import java.nio.file.Path
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import org.apache.commons.io.FilenameUtils
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper.ComparisonResult
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager

import static org.junit.jupiter.api.Assertions.assertEquals

@ExtendWith(TestProjectManager, TestLogging)
abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
    protected var Path testProjectFolder
    var String modelFileExtension
    protected val stateBasedStrategyLogger = new DerivedSequenceProvidingStateBasedChangeResolutionStrategy
    @Accessors(PUBLIC_GETTER) var List<PropagatedChange> propagatedChanges

    /** The <code>StateBasedChangeResolutionStrategy</code> to use. */
    def StateBasedChangeResolutionStrategy getStateBasedResolutionStrategy()

    /**
     * The path to the model which shall be preloaded.
     * @param testInfo the info for the test to execute.
     */
    def Path initialModelPath(TestInfo testInfo)

    @BeforeEach
    protected def void patchDomains() {
        changePropagationSpecifications.forEach [ sourceDomain.stateBasedChangeResolutionStrategy = stateBasedStrategyLogger ]
    }

    @BeforeEach
    protected def setupStrategyLogger() {
        this.propagatedChanges = null
        this.stateBasedStrategyLogger.reset()
        this.stateBasedStrategyLogger.setStrategy(getStateBasedResolutionStrategy())
    }

    @BeforeEach
    protected def setup(@TestProject Path testProjectFolder, TestInfo testInfo) {
        this.testProjectFolder = testProjectFolder
        preloadModel(initialModelPath(testInfo))
    }

    def getDerivedChangeSequence() {
        stateBasedStrategyLogger.getChangeSequence
    }

    protected def resourcesDirectory() {
        Path.of("testresources")
    }

    protected def getSourceModelPath() {
        testProjectFolder.resolve("model").resolve("Model." + modelFileExtension)
    }

    protected def getSourceModel() {
        virtualModel.getModelInstance(VURI.getInstance(sourceModelPath.toString))
    }

    def resolveChangedState(Path changedModelPath) {
        val changedModel = loadExternalModel(changedModelPath)
        val sourceModelURI = VURI.getInstance(sourceModelPath.toString).EMFUri
        propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModelURI)
        logChanges()
        assertSourceModelEquals(changedModelPath.toFile)
    }

    protected def preloadModel(Path path) {
        modelFileExtension = FilenameUtils.getExtension(path.toString)
        val originalModel = loadExternalModel(path)
        resourceAt(sourceModelPath).propagate [
            contents += EcoreUtil.copy(originalModel.contents.head)
        ]

        // preserve original ids
        // this cannot be done in resourceAt as the resource instance is another one than the one in the virtual model
        val model = sourceModel.resource
        ResourceUtil.copyIDs(originalModel, model)
        model.save(emptyMap)

        assertSourceModelEquals(path.toFile)
    }

    protected def loadExternalModel(Path path) {
        val resourceSet = new ResourceSetImpl
        return resourceSet.getResource(URI.createFileURI(path.toFile().getAbsolutePath()), true)
    }

    def <T extends EObject> getModifiableInstance(T original) {
        val originalURI = EcoreUtil.getURI(original)
        return originalURI.trimFragment.resourceAt?.getEObject(originalURI.fragment) as T
    }

    def <T extends EObject> getModifiableCorrespondingObject(EObject original, Class<T> type) {
        return getModifiableCorrespondingObject(original, type, "")
    }

    def <T extends EObject> getModifiableCorrespondingObject(EObject original, Class<T> type, String tag) {
        val correspondences = correspondenceModel.getCorrespondingEObjects(#[original], tag).flatten.filter(type)
        assertEquals(1, correspondences.size)
        return getModifiableInstance(correspondences.head)
    }

    def assertSourceModelEquals(File expected) {
        assertFileOrDirectoryEquals(expected, sourceModelPath.toFile)
    }

    def assertFileOrDirectoryEquals(File expected, File actual) {
        val result = compareFileOrDirectory(expected, actual)
        val incorrectResults = result.filter[_, value|value != ComparisonResult.SEMANTICALLY_IDENTICAL]
        assertEquals(0, incorrectResults.size, '''got incorrect results for files: «incorrectResults»''')
    }

    private def Map<File, ComparisonResult> compareFileOrDirectory(File expected, File actual) {
        val result = new HashMap<File, ComparisonResult>()
        val comparisonResult = compareFiles(expected, actual)
        if (comparisonResult !== null) {
            result.put(actual, comparisonResult)
        }
        val visitedFiles = new HashSet<File>()
        if (expected.isDirectory) {
            for (File file : expected.listFiles().filter[f|!f.hidden]) {
                val relativize = expected.toPath().relativize(file.toPath())
                val fileInOther = actual.toPath().resolve(relativize).toFile()
                visitedFiles += fileInOther
                val subResult = compareFileOrDirectory(file, fileInOther)
                subResult.forEach[key, value|result.put(key, value)]
            }
        }
        if (actual.isDirectory) {
            for (File file : actual.listFiles().filter[f|!f.hidden]) {
                if (!visitedFiles.contains(file)) {
                    result.put(file, ComparisonResult.FILE_SHOULD_NOT_EXIST)
                }
            }
        }
        return result
    }

    def compareFiles(File expected, File actual) {
        return FileComparisonHelper.compareFiles(#[], expected, actual)
    }

    def serializedChanges() {
        '''propagated changes:
	«propagatedChanges»''' + "\n" + '''vitruvius changes:
	«getDerivedChangeSequence()»'''
    }

    def logChanges() {
        val output = testProjectFolder.resolve("Changes.log").toFile
        output.createNewFile
        val writer = new FileWriter(output.absolutePath)
        writer.write(serializedChanges)
        writer.close
    }
}
