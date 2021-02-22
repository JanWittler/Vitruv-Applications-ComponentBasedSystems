package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.junit.jupiter.api.Test
import tools.vitruv.framework.util.datatypes.VURI
import java.util.ArrayList

abstract class SmallGeneratedTest extends GeneratedUml2JavaStateBasedChangeTest {
	@Test
	def void testDeleteClasses() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val deletedClasses = new ArrayList
		deletedClasses += getClass(#[0], 1, model)
		deletedClasses += getClass(#[0], 0, model)
		deletedClasses += getClass(#[0, 0], 2, model)
		deletedClasses += getClass(#[1, 0], 1, model)
		deletedClasses.forEach[destroy]
		resolveChangedState(resource)
	}
	
	@Test
	def void testMoveClasses() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val c00_0 = getClass(#[0, 0], 0, model)
		val c00_1 = getClass(#[0, 0], 1, model)
		val c0_1 = getClass(#[0], 1, model)
		val c1_2 = getClass(#[1], 2, model)
		val c10_0 = getClass(#[1, 0], 0, model)
		getPackage(#[1], model).packagedElements += c00_1
		getPackage(#[0], model).packagedElements += c00_0
		getPackage(#[0,0], model).packagedElements += c0_1
		getPackage(#[0,0], model).packagedElements += c10_0
		getPackage(#[1,0], model).packagedElements += c1_2
		resolveChangedState(resource)
	}
	
	@Test
	def void testRenameClasses() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val c00_0 = getClass(#[0, 0], 0, model)
		val c00_1 = getClass(#[0, 0], 1, model)
		val c0_1 = getClass(#[0], 1, model)
		val c1_2 = getClass(#[1], 2, model)
		val c10_0 = getClass(#[1, 0], 0, model)
		c00_0.name = "Renamed1"
		c00_1.name = "Renamed2"
		c0_1.name = "Renamed3"
		c1_2.name = "Renamed4"
		c10_0.name = "Renamed5"
		resolveChangedState(resource)
	}
	
	@Test
	def void testDeleteMethodsAndAttributes() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val c00_0 = getClass(#[0, 0], 0, model)
		val c00_1 = getClass(#[0, 0], 1, model)
		val c0_1 = getClass(#[0], 1, model)
		val c1_2 = getClass(#[1], 2, model)
		val c10_0 = getClass(#[1, 0], 0, model)
		c00_0.ownedOperations.get(0).destroy
		c00_0.ownedAttributes.get(1).destroy
		c00_1.ownedOperations.get(3).destroy
		c0_1.ownedAttributes.get(0).destroy
		c1_2.ownedOperations.get(1).destroy
		c1_2.ownedOperations.get(0).destroy
		c10_0.ownedAttributes.get(1).destroy
		resolveChangedState(resource)
	}
	
	@Test
	def void testRenameMethodsAndAttributes() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val c00_0 = getClass(#[0, 0], 0, model)
		val c00_1 = getClass(#[0, 0], 1, model)
		val c0_1 = getClass(#[0], 1, model)
		val c1_2 = getClass(#[1], 2, model)
		val c10_0 = getClass(#[1, 0], 0, model)
		c00_0.ownedOperations.get(0).name = "renamed1"
		c00_0.ownedAttributes.get(1).name = "renamed2"
		c00_1.ownedOperations.get(3).name = "renamed3"
		c0_1.ownedAttributes.get(0).name = "renamed4"
		c1_2.ownedOperations.get(1).name = "renamed5"
		c1_2.ownedOperations.get(0).name = "renamed6"
		c10_0.ownedAttributes.get(1).name = "renamed7"
		resolveChangedState(resource)
	}
	
	@Test
	def testRenameSingleMethod() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val operation = getClass(#[0], 1, model).ownedOperations.get(0)
		operation.name = "renamed"
		resolveChangedState(resource)
	}
	
	@Test
	def testRenameSingleAttribute() {
		val resource = loadModel(resourcesDirectory.resolve(INITIAL_MODEL_NAME + "." + MODEL_FILE_EXTENSION))
		val model = resource.contents.head as Model
		val attribute = getClass(#[0, 0], 0, model).ownedAttributes.get(0)
		attribute.name = "renamed"
		resolveChangedState(resource)
	}
	
	def resolveChangedState(Resource changedModel) {
		val sourceModelURI = VURI.getInstance(sourceModelPath.toString).EMFUri
		propagatedChanges = virtualModel.propagateChangedState(changedModel, sourceModelURI)
		logChanges()
	}
	
	override resourcesDirectory() {
		super.resourcesDirectory().resolve("Small")
	}
	
	def getPackage(int[] indexes, Model model) {
		var package = model as Package
		for (i : indexes) {
			package = package.packagedElements.filter(Package).get(i)
		}
		return package
	}
	
	def getClass(int[] packageIndexes, int classIndex, Model model) {
		val package = getPackage(packageIndexes, model)
		return package.packagedElements.filter(Class).get(classIndex)
	}
}