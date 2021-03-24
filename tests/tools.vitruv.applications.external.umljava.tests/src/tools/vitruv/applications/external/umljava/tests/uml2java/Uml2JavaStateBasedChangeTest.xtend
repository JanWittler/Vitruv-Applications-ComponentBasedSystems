package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.nio.file.Path
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.JavaFileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.UMLXMLFileComparisonHelper
import tools.vitruv.domains.java.util.JavaPersistenceHelper
import org.junit.jupiter.api.TestInfo
import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
import tools.vitruv.applications.umljava.JavaToUmlChangePropagationSpecification
import org.junit.jupiter.api.BeforeEach
import tools.vitruv.domains.uml.UmlDomainProvider

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
    override initialModelPath(TestInfo testInfo) {
        return resourcesDirectory.resolve("Base.uml")
    }

    override preloadModel(Path path) {
        super.preloadModel(path)

        renewResourceCache
        val sourceResource = sourceModel.resource
        enrichJavaModel(path, [n, c|retrieveUMLClass(sourceResource, n, c)])

        assertTargetModelEquals(path.parent.resolve("expected_src"))
    }

    @BeforeEach
    override patchDomains() {
        new UmlDomainProvider().domain.stateBasedChangeResolutionStrategy = stateBasedStrategyLogger
    }

    override protected getChangePropagationSpecifications() {
        return #[new UmlToJavaChangePropagationSpecification, new JavaToUmlChangePropagationSpecification]
    }

    /**
     * Called after preloading the UML model and generating the Java model to extend the Java model.
     * Enriching the Java model is required, otherwise any conservative change sequence leads to the correct Java model (assuming correct and complete consistency specification).
     * @param preloadedModelPath The path from which the model used for preloading was taken.
     * @param umlClassProvider A function taking a list of namespaces (the packages) and the name of the class as arguments and returning the appropriate uml class.
     */
    def void enrichJavaModel(Path preloadedModelPath, (List<String>, String)=>Class umlClassProvider)

    /**
     * Loads the changed UML model contained in the provided directory, generates the change sequence, 
     * and propagates changes to the Java domain.
     * The directory is resolved relative to the {@link Uml2JavaStateBasedChangeTest#resourcesDirectory resources directory}.
     * Verifies the correctness of the source and target model.
     * The model is assumed to be at <code>/Model.uml</code>.
     * The expected java source files are assumed to be at <code>/expected_src</code>.
     * @param directory The directory in which the files to test reside.
     */
    def testModelInDirectory(String directory) {
        val testDirectory = resourcesDirectory().resolve("tests").resolve(directory)
        resolveChangedState(testDirectory.resolve("Model.uml"))
        assertTargetModelEquals(testDirectory.resolve("expected_src"))
    }

    def assertTargetModelEquals(Path expected) {
        val targetModelFolder = testProjectFolder.resolve(JavaPersistenceHelper.javaProjectSrc)
        assertFileOrDirectoryEquals(expected.toFile, targetModelFolder.toFile)
    }

    private def retrieveUMLClass(Resource umlResource, List<String> packages, String className) {
        val umlModel = umlResource.contents.filter(Model).head
        var umlPackage = umlModel as Package
        for (packageName : packages) {
            umlPackage = umlPackage?.packagedElements.filter(Package).filter[name == packageName].head
        }
        return umlPackage.packagedElements.filter(Class).filter[name == className].head
    }

    val fileComparisonHelpers = #[new JavaFileComparisonHelper, new UMLXMLFileComparisonHelper]

    override compareFiles(File expected, File actual) {
        return FileComparisonHelper.compareFiles(fileComparisonHelpers, expected, actual)
    }
}
