package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.nio.file.Path
import java.util.List
import org.apache.commons.io.FilenameUtils
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import tools.vitruv.applications.external.umljava.tests.util.UMLXMLComparisonHelper
import tools.vitruv.domains.java.util.JavaPersistenceHelper

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
    override preloadModel(Path path) {
        super.preloadModel(path)

        renewResourceCache
        val sourceResource = sourceModel.resource
        enrichJavaModel(path, [n, c|retrieveUMLClass(sourceResource, n, c)])

        assertTargetModelEquals(path.parent.resolve("expected_src"))
    }

    def void enrichJavaModel(Path preloadedModelPath, (List<String>, String)=>Class umlClassProvider)

    def testModels(String directory) {
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

    override compareFiles(File expected, File actual) {
        val result = super.compareFiles(expected, actual)
        if (result == FileComparisonResult.CORRECT) {
            return result
        }
        val e1 = FilenameUtils.getExtension(expected.toString)
        val e2 = FilenameUtils.getExtension(actual.toString)
        if (e1 == e2) {
            if (e1 == "java") {
                return compareJavaFiles(expected, actual)
            } else if (e1 == "uml") {
                return compareUMLFiles(expected, actual)
            }
        }
        return result
    }

    /**
     * Compares two java files.
     * The comparison compares each line of the files for equality, leading or trailing whitespaces are ignored.
     * Empty lines are ignored.
     * Spaces before semicolon are ignored.
     * Lines starting with an import statement are ignored as imports are currently not cleaned up by the consistency mechanism.
     */
    def compareJavaFiles(File expected, File actual) {
        val readerExpected = new BufferedReader(new FileReader(expected))
        val readerActual = new BufferedReader(new FileReader(actual))

        var lineExpected = readerExpected.readLineTrimmed
        var lineActual = readerActual.readLineTrimmed
        while (lineExpected !== null || lineActual !== null) {
            if (lineExpected !== null && (lineExpected.startsWith("import") || lineExpected.empty)) {
                lineExpected = readerExpected.readLineTrimmed
            } else if (lineActual !== null && (lineActual.startsWith("import") || lineActual.empty)) {
                lineActual = readerActual.readLineTrimmed
            } else {
                if (lineExpected != lineActual) {
                    return FileComparisonResult.INCORRECT_FILE
                }
                lineExpected = readerExpected.readLineTrimmed
                lineActual = readerActual.readLineTrimmed
            }
        }
        return FileComparisonResult.CORRECT
    }

    private def readLineTrimmed(BufferedReader reader) {
        reader.readLine?.trim?.replace(" ;", ";")
    }

    def compareUMLFiles(File expected, File actual) {
        return UMLXMLComparisonHelper.compareUMLFiles(expected, actual)
            ? FileComparisonResult.CORRECT
            : FileComparisonResult.INCORRECT_FILE
    }
}
