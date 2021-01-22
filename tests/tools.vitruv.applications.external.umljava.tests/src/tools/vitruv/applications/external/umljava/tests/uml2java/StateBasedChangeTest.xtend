package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.applications.external.umljava.tests.util.CustomizableUmlToJavaChangePropagationSpecification
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager
import java.io.File
import org.apache.commons.io.FileUtils
import java.util.Map

import static org.junit.jupiter.api.Assertions.assertEquals
import java.util.HashSet
import java.util.HashMap

@ExtendWith(TestProjectManager, TestLogging)
abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
	public static val RESOURCESPATH = "testresources"
	public static val INITIALMODELNAME = "Base"
	public static val MODELFILEEXTENSION ="uml"
	
	protected var Path testProjectFolder
	val stateBasedStrategyLogger = new DerivedSequenceProvidingStateBasedChangeResolutionStrategy()
	@Accessors(PUBLIC_GETTER) var List<PropagatedChange> propagatedChanges
	
	def StateBasedChangeResolutionStrategy getStateBasedResolutionStrategy()
	
	@BeforeEach
	def void setup(@TestProject Path testProjectFolder) {
		this.testProjectFolder = testProjectFolder
		this.propagatedChanges = null
		this.stateBasedStrategyLogger.reset()
		this.stateBasedStrategyLogger.setStrategy(getStateBasedResolutionStrategy())
		
		preloadModel(resourcesDirectory.resolve(INITIALMODELNAME + "." + MODELFILEEXTENSION))
	}
	
	override protected getChangePropagationSpecifications() {
		val spec = new CustomizableUmlToJavaChangePropagationSpecification()
		spec.setStateBasedChangeResolutionStrategyForUmlDomain(stateBasedStrategyLogger)
		return #[spec]; 
	}
	
	def getDerivedChangeSequence() {
		stateBasedStrategyLogger.getChangeSequence()
	}
	
	def getModelsDirectory() {
		testProjectFolder.resolve("model")
	}
	
	def resourcesDirectory() {
		Path.of(RESOURCESPATH)
	}
	
	def getSourceModelPath() {
		modelsDirectory.resolve("Model." + MODELFILEEXTENSION)
	}
	
	def resolveChangedState(Path changedModelPath) {
		val changedModel = loadModel(changedModelPath)
		val sourceModelURI = VURI.getInstance(sourceModelPath.toString).EMFUri
		propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModelURI)
		assertSourceModelEquals(changedModelPath.toFile)
	}
	
	private def preloadModel(Path path) {
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
	
	private def Map<File, Uml2JavaStateBasedChangeTest.FileComparisonResult> internalFileOrDirectoryEqual(File expected, File actual) {
		val result = new HashMap<File, Uml2JavaStateBasedChangeTest.FileComparisonResult>()
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
	
	def void printChanges() {
		println('''propagated changes:
	«propagatedChanges»''')
		println('''vitruvius changes:
	«getDerivedChangeSequence()»''')
	}
}