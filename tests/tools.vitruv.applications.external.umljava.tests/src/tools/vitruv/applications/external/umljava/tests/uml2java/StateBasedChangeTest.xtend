package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.io.FileWriter
import java.nio.file.Path
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import org.apache.commons.io.FileUtils
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
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
	public static val INITIAL_MODEL_NAME = "Base"
	public static val MODEL_FILE_EXTENSION ="uml"
	
	/** For any test case tagged with this tag, the model preloading will be skipped. */
	public static val CUSTOM_INITIAL_MODEL_TAG = "StateBasedChangeTest.CustomInitialModel"
	
	protected var Path testProjectFolder
	val stateBasedStrategyLogger = new DerivedSequenceProvidingStateBasedChangeResolutionStrategy()
	@Accessors(PUBLIC_GETTER) protected var List<PropagatedChange> propagatedChanges
	
	def StateBasedChangeResolutionStrategy getStateBasedResolutionStrategy()
	
	@BeforeEach
	def setupStrategyLogger() {
		this.propagatedChanges = null
		this.stateBasedStrategyLogger.reset()
		this.stateBasedStrategyLogger.setStrategy(getStateBasedResolutionStrategy())
	}
	
	@BeforeEach
	def setup(@TestProject Path testProjectFolder, TestInfo testInfo) {
		this.testProjectFolder = testProjectFolder
		
		if (!testInfo.tags.contains(CUSTOM_INITIAL_MODEL_TAG)) {
			preloadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		}
	}
	
	override protected getChangePropagationSpecifications() {
		val spec = new UmlToJavaChangePropagationSpecification()
		spec.sourceDomain.stateBasedChangeResolutionStrategy = stateBasedStrategyLogger
		return #[spec]
	}
	
	def getDerivedChangeSequence() {
		stateBasedStrategyLogger.getChangeSequence()
	}
	
	def getModelsDirectory() {
		testProjectFolder.resolve("model")
	}
	
	def resourcesDirectory() {
		Path.of("testresources")
	}
	
	def getSourceModelPath() {
		modelsDirectory.resolve("Model." + MODEL_FILE_EXTENSION)
	}
	
	def resolveChangedState(Path changedModelPath) {
		val changedModel = loadModel(changedModelPath)
		val sourceModelURI = VURI.getInstance(sourceModelPath.toString).EMFUri
		propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModelURI)
		assertSourceModelEquals(changedModelPath.toFile)
	}
	
	def preloadModel(Path path) {
		val originalModel = loadModel(path)
		resourceAt(sourceModelPath).record [
			contents += EcoreUtil.copy(originalModel.contents.head)
		]
		propagate
		
		//preserve original ids
		val model = virtualModel.getModelInstance(VURI.getInstance(sourceModelPath.toString)).resource
		ResourceUtil.copyIDs(originalModel, model)
		model.save(emptyMap)
		
		assertSourceModelEquals(path.toFile)
	}
	
	def loadModel(Path path) {
		val resourceSet = new ResourceSetImpl
		return resourceSet.getResource(URI.createFileURI(path.toFile().getAbsolutePath()), true)
	}
	
	enum FileComparisonResult {
		CORRECT,
		MISSING_FILE,
		DIR_INSTEAD_OF_FILE,
		FILE_INSTEAD_OF_DIR,
		INCORRECT_FILE,
		FILE_SHOULD_NOT_EXIST
	}
	
	def assertSourceModelEquals(File expected) {
		assertFileOrDirectoryEquals(expected, sourceModelPath.toFile)
	}
	
	def assertFileOrDirectoryEquals(File expected, File actual) {
		val result = internalFileOrDirectoryEqual(expected, actual)
		val incorrectResults = result.filter[_, value | value != FileComparisonResult.CORRECT]
		assertEquals(0, incorrectResults.size, '''got incorrect results for files: «incorrectResults»''')
	}
	
	private def Map<File, FileComparisonResult> internalFileOrDirectoryEqual(File expected, File actual) {
		val result = new HashMap<File, StateBasedChangeTest.FileComparisonResult>()
		if (!actual.exists) {
			result.put(actual, FileComparisonResult.MISSING_FILE)
		}
		else if (!expected.isDirectory == actual.isDirectory) {
			result.put(actual, actual.isDirectory ? FileComparisonResult.DIR_INSTEAD_OF_FILE : FileComparisonResult.FILE_INSTEAD_OF_DIR)
		}
		else {
			if (expected.isDirectory) {
				val visitedFiles = new HashSet<File>()
				for (File file: expected.listFiles().filter[f|!f.hidden]) {
					val relativize = expected.toPath().relativize(file.toPath())
					val fileInOther = actual.toPath().resolve(relativize).toFile()
					visitedFiles += fileInOther
					val subResult = internalFileOrDirectoryEqual(file, fileInOther)
					subResult.forEach[key, value | result.put(key, value)]
				}
				for (File file: actual.listFiles().filter[f|!f.hidden]) {
					if (!visitedFiles.contains(file)) {
						result.put(file, FileComparisonResult.FILE_SHOULD_NOT_EXIST)
					}
				}
			}
			else {
				result.put(actual, compareFiles(expected, actual))
			}
		}
		return result
	}
	
	def compareFiles(File expected, File actual) {
		if (FileUtils.contentEquals(expected, actual)) {
			return FileComparisonResult.CORRECT
		}
		return FileComparisonResult.INCORRECT_FILE
	}
	
	def serializedChanges() {
		'''propagated changes:
	«propagatedChanges»''' + "\n" +
		'''vitruvius changes:
	«getDerivedChangeSequence()»'''
	}
	
	def logChanges() {
		val output = testProjectFolder.resolve("Changes.log").toFile
		output.createNewFile
		val writer = new FileWriter(output.absolutePath)
		writer.write(serializedChanges)
		writer.close
	}
	
	final def printChanges() {
		println(serializedChanges)
	}
}