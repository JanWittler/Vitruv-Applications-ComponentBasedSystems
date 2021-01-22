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
}