package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.jupiter.api.BeforeEach
import tools.vitruv.applications.external.umljava.tests.util.CustomizableUmlToJavaChangePropagationSpecification
import tools.vitruv.external.applications.external.strategies.DerivedSequenceProvidingStateBasedChangeResolutionStrategy
import tools.vitruv.framework.change.description.PropagatedChange
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestProject
import java.util.List

abstract class StateBasedChangeTest extends LegacyVitruvApplicationTest {
	static val MODELPATH = "testresources"
	static val INITIALMODELNAME = "Example.uml"
	
	protected var Path testProjectFolder
	val stateBasedStrategyLogger = new DerivedSequenceProvidingStateBasedChangeResolutionStrategy()
	@Accessors(PUBLIC_GETTER) var Resource sourceModel
	@Accessors(PUBLIC_GETTER) var List<PropagatedChange> propagatedChanges
	
	def StateBasedChangeResolutionStrategy getStateBasedResolutionStrategy()
	
	@BeforeEach
	def void setup(@TestProject Path testProjectFolder) {
		this.testProjectFolder = testProjectFolder
		this.stateBasedStrategyLogger.reset()
		this.stateBasedStrategyLogger.setStrategy(getStateBasedResolutionStrategy())
		
		preloadModel(Path.of(MODELPATH).resolve(INITIALMODELNAME), INITIALMODELNAME)
	}
	
	override protected getChangePropagationSpecifications() {
		val spec = new CustomizableUmlToJavaChangePropagationSpecification()
		spec.setStateBasedChangeResolutionStrategyForUmlDomain(stateBasedStrategyLogger)
		return #[spec]; 
	}
	
	def getDerivedChangeSequence() {
		return stateBasedStrategyLogger.getChangeSequence()
	}
	
	def resolveChangedState(Path changedModelPath) {
		val changedModel = loadModel(changedModelPath)
		propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModel?.URI)
	}
	
	def modelsDirectory() {
		return testProjectFolder.resolve("model")
	}
	
	private def preloadModel(Path path, String modelName) {
		val modelPath = modelsDirectory.resolve(modelName)
		
		//createAndSynchronizeModel
		sourceModel = resourceAt(modelPath)
		getChangeRecorder().addToRecording(sourceModel)
		sourceModel.contents += loadModel(path).getContents().get(0)
		
		//preserve original ids
		val originalModel = loadModel(path)
		if (originalModel instanceof XMLResource && sourceModel instanceof XMLResource) {
			var i = 0;
			while (i < originalModel.getContents().size() && i < sourceModel.getContents().size) {
				propagateID(originalModel.getContents().get(i), sourceModel.getContents().get(i))
				i += 1
			}
		}
		saveAndSynchronizeChanges(originalModel.getContents().get(0))
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
	
	def logChanges() {
		println('''propagated changes:
		«propagatedChanges»''')
		println('''vitruvius changes:
		«getDerivedChangeSequence()»''')
	}
	
}