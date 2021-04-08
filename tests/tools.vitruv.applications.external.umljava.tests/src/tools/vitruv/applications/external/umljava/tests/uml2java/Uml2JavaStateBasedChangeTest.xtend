package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.nio.file.Path
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.emftext.language.java.containers.CompilationUnit
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInfo
import tools.vitruv.applications.external.umljava.tests.util.FileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.JavaFileComparisonHelper
import tools.vitruv.applications.external.umljava.tests.util.UMLXMLFileComparisonHelper
import tools.vitruv.applications.umljava.JavaToUmlChangePropagationSpecification
import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
import tools.vitruv.domains.java.util.JavaPersistenceHelper
import tools.vitruv.domains.uml.UmlDomainProvider

/**
 * The basic test class for UML to Java state based change tests.
 * Automatically verifies the correct of the target model after preloading the source model and propagating changes.
 * 
 * @author Jan Wittler
 */
abstract class Uml2JavaStateBasedChangeTest extends StateBasedChangeDifferencesTest {
    override initialModelPath(TestInfo testInfo) {
        return resourcesDirectory.resolve("Model.uml")
    }

    override preloadModel(Path path) {
        super.preloadModel(path)

        renewResourceCache
        extendJavaModel(path, [n, c|retrieveJavaClassifier(c, n)])

        assertTargetModelEquals(path.parent.resolve("expected_src"))
    }

    @BeforeEach
    override patchDomains() {
        new UmlDomainProvider().domain.stateBasedChangeResolutionStrategy = traceableStateBasedStrategy
    }

    override protected getChangePropagationSpecifications() {
        return #[new UmlToJavaChangePropagationSpecification, new JavaToUmlChangePropagationSpecification]
    }

    /**
     * Called after preloading the UML model and generating the Java model to extend the Java model.
     * Extending the Java model is required, otherwise any conservative change sequence leads to the correct Java model (assuming correct and complete consistency specification).
     * @param preloadedModelPath The path from which the model used for preloading was taken.
     * @param javaClassifierProvider A function taking a sequence of namespaces (the packages) and the name of the classifier as arguments and returning the matching Java classifier.
     */
    def void extendJavaModel(Path preloadedModelPath, (Iterable<String>, String)=>ConcreteClassifier javaClassifierProvider)

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

    private def retrieveJavaClassifier(String className, Iterable<String> namespaces) {
        val path = testProjectFolder.resolve(JavaPersistenceHelper.buildJavaFilePath(className + ".java", namespaces))
        val compilationUnit = resourceAt(path).contents.head as CompilationUnit
        return compilationUnit.classifiers.filter [ name == className ].head
    }

    val fileComparisonHelpers = #[new JavaFileComparisonHelper, new UMLXMLFileComparisonHelper]

    override compareFiles(File expected, File actual) {
        return FileComparisonHelper.compareFiles(fileComparisonHelpers, expected, actual)
    }
}
