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
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.applications.external.strategies.TraceableStateBasedChangeResolutionStrategy
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper.ComparisonResult
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertFalse
import tools.vitruv.applications.external.umljava.tests.util.TimeMeasurement
import com.google.common.base.Stopwatch
import org.eclipse.emf.ecore.resource.Resource

/**
 * The basic test class for state based change propagation tests.
 * Before each tests, preloads a source model and verifies its correctness, and generates the corresponding target model.
 * Logs the propagated and derived change sequence to a file in the test directory.
 * Provides support for directory comparison and accessing modifiable corresponding objects of source model objects.
 * 
 * @author Jan Wittler
 */
@ExtendWith(TestProjectManager, TestLogging)
abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
    protected var Path testProjectFolder
    var TestInfo testInfo
    var String modelFileExtension
    @Accessors(PROTECTED_GETTER) var isModelPreloaded = false
    protected val traceableStateBasedStrategy = new TraceableStateBasedChangeResolutionStrategy
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
        changePropagationSpecifications.forEach [
            sourceDomain.stateBasedChangeResolutionStrategy = traceableStateBasedStrategy
        ]
    }

    @BeforeEach
    def setupStrategyLogger() {
        this.traceableStateBasedStrategy.strategy = stateBasedResolutionStrategy
    }

    @BeforeEach
    protected def void setup(@TestProject Path testProjectFolder, TestInfo testInfo) {
        this.testProjectFolder = testProjectFolder
        this.testInfo = testInfo
        isModelPreloaded = false
    }

    def getDerivedChangeSequence() {
        traceableStateBasedStrategy.getChangeSequence
    }

    /** The directory where all test resources are. By defaults returns <code>/testresources</code>. */
    protected def resourcesDirectory() {
        Path.of("testresources")
    }

    protected def getSourceModelPath() {
        testProjectFolder.resolve("model").resolve("Model." + modelFileExtension)
    }

    protected def getSourceModel() {
        virtualModel.getModelInstance(sourceModelPath.uri)
    }

    /**
     * Resolves a changed model with the current VSUM.
     * Logs the performed changes to file and validates the correctness of the source model after propagation.
     * @param changedModelPath The path of the changed model.
     */
    def resolveChangedState(Path changedModelPath) {
        val changedModel = loadExternalModel(changedModelPath)
        resolveChangedState(changedModel)
        assertSourceModelEquals(changedModelPath.toFile)
    }

    def resolveChangedState(Resource changedModel) {
        val sourceModelURI = sourceModelPath.uri
        TimeMeasurement.shared.startTest(testInfo, class.name)
        val stopwatch = Stopwatch.createStarted()
        propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModelURI)
        stopwatch.stop
        TimeMeasurement.shared.addStopwatchForKey(stopwatch, "overall")
        TimeMeasurement.shared.stopAndLogActiveTest()
        logChanges()

        // preserve original ids
        // should be done by the change propagation
        val model = sourceModel.resource
        ResourceUtil.copyIDs(changedModel, model)
        model.save(emptyMap)
    }

    final def preloadModel() {
        preloadModel(initialModelPath(testInfo))
        this.traceableStateBasedStrategy.reset()
        this.propagatedChanges = null
    }

    protected def preloadModel(Path path) {
        assertFalse(isModelPreloaded, "duplicate preloading of model")
        isModelPreloaded = true

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

    def assertSourceModelEquals(File expected) {
        assertFileOrDirectoryEquals(expected, sourceModelPath.toFile)
    }

    /**
     * Asserts that the two provided file objects contain equal content.
     * If directories are provided, a deep comparison of the directories content is performed.
     * If files are provided, they are compared for equality. 
     * To compare files @{link #compareFiles(File,File)} is used.
     * @param The file or directory expected.
     * @param The file or directory actually present.
     */
    def assertFileOrDirectoryEquals(File expected, File actual) {
        val result = compareFileOrDirectory(expected, actual)
        val incorrectResults = result.filter[_, value|value != ComparisonResult.SEMANTICALLY_IDENTICAL]
        assertEquals(0, incorrectResults.size, '''got incorrect results for files: «incorrectResults»''')
    }

    /**
     * Compares two files for equality. Uses @{link FileComparisonHelper} to compare files.
     * @param expected The expected file.
     * @param actual The actual file.
     * @return Returns <code>true</code> if both files are semantically identical, otherwise <code>false</code>.
     */
    def compareFiles(File expected, File actual) {
        return FileComparisonHelper.compareFiles(#[], expected, actual)
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
