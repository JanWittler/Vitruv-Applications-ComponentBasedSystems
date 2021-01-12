package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import tools.vitruv.applications.external.umljava.tests.util.CustomizableUmlToJavaChangePropagationSpecification
import tools.vitruv.external.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestProject

abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
	static val RESOURCESPATH = "testresources"
	static val INITIALMODELNAME = "Example.uml"
	
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
		
		preloadModel(resourcesDirectory.resolve(INITIALMODELNAME), INITIALMODELNAME)
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
		val modelPath = modelsDirectory.resolve(INITIALMODELNAME)
		return VURI.getInstance(modelPath.toString)
	}
	
	def resolveChangedState(Path changedModelPath) {
		val changedModel = loadModel(changedModelPath)
		propagatedChanges = virtualModel.propagateChangedState(changedModel, getSourceModelVuri().EMFUri)
	}
	
	private def preloadModel(Path path, String modelName) {
		val modelPath = modelsDirectory.resolve(modelName)
		val originalModel = loadModel(path)
		createAndSynchronizeModel(modelPath.toString, EcoreUtil.copy(originalModel.contents.get(0)))
		
		//preserve original ids
		val model = virtualModel.getModelInstance(sourceModelVuri).resource
		if (originalModel instanceof XMLResource && model instanceof XMLResource) {
			var i = 0;
			while (i < originalModel.contents.size() && i < model.contents.size) {
				propagateID(originalModel.contents.get(i), model.contents.get(i))
				i += 1
			}
			model.save(emptyMap)
		}
	}
	
	private def void propagateID(EObject orig, EObject copy) {
		(copy.eResource() as XMLResource).setID(copy, (orig.eResource() as XMLResource).getID(orig));
		var i = 0;
		while (i < orig.eContents().size() && i < copy.eContents().size) {
			propagateID(orig.eContents().get(i), copy.eContents().get(i))
			i += 1
		}
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