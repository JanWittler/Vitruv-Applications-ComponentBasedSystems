package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import java.util.ArrayList
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation
import org.junit.jupiter.api.Order
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.TestMethodOrder
import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification

@TestMethodOrder(OrderAnnotation)
abstract class SmallGeneratedTest extends GeneratedUml2JavaStateBasedChangeTest {
    override protected getChangePropagationSpecifications() {
        return #[new UmlToJavaChangePropagationSpecification]
    }

    override initialModelPath(TestInfo testInfo) {
        return resourcesDirectory.resolve("Base.uml")
    }

    @Test
    @Order(1)
    def initCache() {
        val resource = getRootModel()
        val model = resource.contents.head as Model
        getClass(#[0], 1, model).destroy
        resolveChangedState(resource)
    }

    @Test
    def void testDeleteClasses() {
        val resource = getRootModel()
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
        val resource = getRootModel()
        val model = resource.contents.head as Model
        val c00_0 = getClass(#[0, 0], 0, model)
        val c00_1 = getClass(#[0, 0], 1, model)
        val c0_1 = getClass(#[0], 1, model)
        val c1_2 = getClass(#[1], 2, model)
        val c10_0 = getClass(#[1, 0], 0, model)
        getPackage(#[1], model).packagedElements += c00_1
        getPackage(#[0], model).packagedElements += c00_0
        getPackage(#[0, 0], model).packagedElements += c0_1
        getPackage(#[0, 0], model).packagedElements += c10_0
        getPackage(#[1, 0], model).packagedElements += c1_2
        resolveChangedState(resource)
    }

    @Test
    def void testRenameClasses() {
        val resource = getRootModel()
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
        val resource = getRootModel()
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
        val resource = getRootModel()
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
        val resource = getRootModel()
        val model = resource.contents.head as Model
        val operation = getClass(#[0], 1, model).ownedOperations.get(0)
        operation.name = "renamed"
        resolveChangedState(resource)
    }

    @Test
    def testRenameSingleAttribute() {
        val resource = getRootModel()
        val model = resource.contents.head as Model
        val attribute = getClass(#[0, 0], 0, model).ownedAttributes.get(0)
        attribute.name = "renamed"
        resolveChangedState(resource)
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

    def getRootModel() {
        if (!isModelPreloaded) {
            preloadModel()
        }
        val path = initialModelPath(null)
        return loadExternalModel(path)
    }
}
