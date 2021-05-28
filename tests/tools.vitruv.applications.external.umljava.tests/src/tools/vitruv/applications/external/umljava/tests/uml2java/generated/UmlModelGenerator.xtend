package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import java.nio.file.Path
import java.util.Random
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.UMLFactory
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.Test
import tools.vitruv.testutils.LegacyVitruvApplicationTest
import tools.vitruv.testutils.TestProject
import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
import org.eclipse.uml2.uml.Operation
import tools.vitruv.applications.util.temporary.uml.UmlTypeUtil
import org.eclipse.uml2.uml.Parameter

@Disabled("kept for comprehensibility of how the uml models got generated")
class UmlModelGenerator extends LegacyVitruvApplicationTest {
    static val PROPERTIES_PER_CLASS = 4 ..< 8
    static val OPERATIONS_PER_CLASS = 3 ..< 6
    static val PARAMETERS_PER_OPERATION = 0 ..< 5

    protected var Path testProjectFolder
    protected var Random random

    @BeforeEach
    def void setup(@TestProject Path testProjectFolder) {
        this.testProjectFolder = testProjectFolder
        this.random = new Random(0) // static seed for reproducibility
    }

    @Disabled
    @Test
    def void generateSmallModel() {
        createUMLModel(#[2, 1], 3)
    }

    @Test
    def void generateLargeModel() {
        createUMLModel(#[3, 2, 2, 2, 2, 2, 2], 10)
    }

    override protected getChangePropagationSpecifications() {
        return #[new UmlToJavaChangePropagationSpecification]
    }

    def createUMLModel(int[] packageCountPerLevel, int classesPerPackage) {
        val sourceModelPath = testProjectFolder.resolve("model").resolve("Base.uml")
        val resource = resourceAt(sourceModelPath)
        generateUMLModel(resource, packageCountPerLevel, classesPerPackage)
        resource.save(emptyMap)
    }

    def generateUMLModel(Resource resource, int[] packageCountPerLevel, int classesPerPackage) {
        val model = UMLFactory.eINSTANCE.createModel
        resource.contents += model
        model.name = "Root"
        val topLevelPackageCount = packageCountPerLevel.head
        for (packageIndex : 0 ..< topLevelPackageCount) {
            val package = UMLFactory.eINSTANCE.createPackage
            model.packagedElements += package
            populatePackage(package, '''«packageIndex + 1»''', classesPerPackage, packageCountPerLevel.drop(1))
        }
    }

    private def void populatePackage(Package pPackage, String packageId, int classesPerPackage,
        int[] packageCountPerLevel) {
        pPackage.name = '''package«packageId»'''
        for (classIndex : 0 ..< classesPerPackage) {
            val class = UMLFactory.eINSTANCE.createClass
            pPackage.packagedElements += class
            populateClass(class, '''«packageId»_«classIndex + 1»''')
        }
        val subpackagesCount = packageCountPerLevel.head
        if (subpackagesCount !== null) {
            for (i : 0 ..< subpackagesCount) {
                val subpackage = UMLFactory.eINSTANCE.createPackage
                pPackage.packagedElements += subpackage
                populatePackage(subpackage, '''«packageId»s«i + 1»''', classesPerPackage, packageCountPerLevel.drop(1))
            }
        }
    }

    private def populateClass(Class pClass, String classId) {
        pClass.name = '''Class«classId»'''
        val propertiesCount = random.nextInt(PROPERTIES_PER_CLASS.max) + PROPERTIES_PER_CLASS.min
        for (i : 0 ..< propertiesCount) {
            val property = UMLFactory.eINSTANCE.createProperty
            pClass.ownedAttributes += property
            populateProperty(property, '''«classId»_«i + 1»''')
        }
        val operationsCount = random.nextInt(OPERATIONS_PER_CLASS.max) + OPERATIONS_PER_CLASS.min
        for (i : 0 ..< operationsCount) {
            val operation = UMLFactory.eINSTANCE.createOperation
            pClass.ownedOperations += operation
            populateOperation(operation, '''«classId»_«i + 1»''')
        }
    }

    private def populateProperty(Property property, String propertyId) {
        property.name = '''attribute«propertyId»'''
        property.type = randomPrimitiveType
    }

    private def populateOperation(Operation operation, String operationId) {
        operation.name = '''method«operationId»'''
        val returnVoid = random.nextBoolean
        if (!returnVoid) {
            operation.type = randomPrimitiveType
        }
        val parametersCount = random.nextInt(PARAMETERS_PER_OPERATION.max) + PARAMETERS_PER_OPERATION.min
        for (i : 0 ..< parametersCount) {
            val parameter = UMLFactory.eINSTANCE.createParameter
            operation.ownedParameters += parameter
            populateParameter(parameter, '''«operationId»_«i + 1»''')
        }
    }

    private def populateParameter(Parameter parameter, String parameterId) {
        parameter.name = '''p«parameterId»'''
        parameter.type = randomPrimitiveType
    }

    private def randomPrimitiveType() {
        val primitiveTypes = UmlTypeUtil.getSupportedPredefinedUmlPrimitiveTypes([uri|uri.resourceAt]).filter [
            name != "UnlimitedNatural"
        ]
        val index = random.nextInt(primitiveTypes.size)
        return primitiveTypes.get(index)
    }
}
