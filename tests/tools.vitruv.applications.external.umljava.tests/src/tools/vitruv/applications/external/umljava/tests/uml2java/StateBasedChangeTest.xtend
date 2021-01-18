package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.nio.file.Path
import java.util.HashSet
import java.util.List
import org.apache.commons.io.FileUtils
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.applications.external.umljava.tests.util.CustomizableUmlToJavaChangePropagationSpecification
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.external.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager

import static org.junit.jupiter.api.Assertions.assertTrue

@ExtendWith(TestProjectManager, TestLogging)
abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
	static val RESOURCESPATH = "testresources"
	static val INITIALMODELNAME = "Base"
	static val MODELFILEEXTENSION ="uml"
	
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
		return stateBasedStrategyLogger.getChangeSequence()
	}
	
	def getModelsDirectory() {
		return testProjectFolder.resolve("model")
	}
	
	def resourcesDirectory() {
		return Path.of(RESOURCESPATH)
	}
	
	def getSourceModelVuri() {
		val modelPath = modelsDirectory.resolve("Model." + MODELFILEEXTENSION)
		return VURI.getInstance(modelPath.toString)
	}
	
	def resolveChangedState(Path changedModelPath) {
		val changedModel = loadModel(changedModelPath)
		propagatedChanges = virtualModel.propagateChangedState(changedModel, getSourceModelVuri().EMFUri)
	}
	
	private def preloadModel(Path path) {
		val originalModel = loadModel(path)
		createAndSynchronizeModel(sourceModelVuri.toResolvedAbsolutePath, EcoreUtil.copy(originalModel.contents.head))
		
		//preserve original ids
		val model = virtualModel.getModelInstance(sourceModelVuri).resource
		ResourceUtil.copyIDs(originalModel, model)
		model.save(emptyMap)
	}
	
	def loadModel(Path path) {
		val resourceSet = new ResourceSetImpl
		return resourceSet.getResource(URI.createFileURI(path.toFile().getAbsolutePath()), true)
	}
	
	def void printChanges() {
		println('''propagated changes:
	«propagatedChanges»''')
		println('''vitruvius changes:
	«getDerivedChangeSequence()»''')
	}
	
	def assertTargetModelEquals(Path expected) {
		val targetModelFolder = testProjectFolder.resolve("src")
		assertDirectoriesEqual(expected.toFile(), targetModelFolder.toFile())
	}
	
	def void assertDirectoriesEqual(File expected, File actual) {
		var visitedFiles = new HashSet<File>()
		for (File file: expected.listFiles().filter[f|!f.hidden]) {
			val relativize = expected.toPath().relativize(file.toPath())
			val fileInOther = actual.toPath().resolve(relativize).toFile()
			visitedFiles += fileInOther
			
			assertTrue(fileInOther.exists, '''[missing file] «fileInOther»''')
			assertTrue(file.isDirectory == fileInOther.isDirectory, '''[«fileInOther.isDirectory ? "dir instead of file" : "file instead of dir"»] «fileInOther»''')
			
			if (file.isDirectory) {
				assertDirectoriesEqual(file, fileInOther)
			}
			else {
				assertTrue(FileUtils.contentEquals(file, fileInOther), '''[incorrect file] «fileInOther»''')
			}
		}
		for (File file: actual.listFiles().filter[f|!f.hidden]) {
			assertTrue(visitedFiles.contains(file), '''[file should not exist] «file»''')
		}
	}
	
}