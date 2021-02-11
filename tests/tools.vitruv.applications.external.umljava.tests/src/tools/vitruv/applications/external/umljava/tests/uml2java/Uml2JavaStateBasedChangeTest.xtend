package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.BufferedReader
import java.io.File
import java.io.FileInputStream
import java.io.FileReader
import java.io.InputStreamReader
import java.nio.file.Path
import org.apache.commons.io.FilenameUtils
import org.custommonkey.xmlunit.Difference
import org.custommonkey.xmlunit.DifferenceConstants
import org.custommonkey.xmlunit.DifferenceListener
import org.custommonkey.xmlunit.XMLUnit
import org.w3c.dom.Node
import org.xml.sax.InputSource
import tools.vitruv.domains.java.util.JavaPersistenceHelper

import static org.custommonkey.xmlunit.XMLUnit.*

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
	override preloadModel(Path path) {
		super.preloadModel(path)
		enrichJavaModel(path)
		assertTargetModelEquals(path.parent.resolve("expected_src"))
	}
	
	def void enrichJavaModel(Path preloadedModelPath)
	
	def testModels(String directory) {
		val testDirectory = resourcesDirectory().resolve("tests").resolve(directory)
		resolveChangedState(testDirectory.resolve("Model.uml"))
		assertTargetModelEquals(testDirectory.resolve("expected_src"))
	}
	
	def assertTargetModelEquals(Path expected) {
		val targetModelFolder = testProjectFolder.resolve(JavaPersistenceHelper.javaProjectSrc)
		assertFileOrDirectoryEquals(expected.toFile, targetModelFolder.toFile)
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
			}
			else if (e1 == "uml") {
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
			}
			else if (lineActual !== null && (lineActual.startsWith("import") || lineActual.empty)) {
				lineActual = readerActual.readLineTrimmed
			}
			else {
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
		val expectedStream = new FileInputStream(expected)
		val expectedSource = new InputSource(new InputStreamReader(expectedStream))
		val actualStream = new FileInputStream(actual)
		val actualSource = new InputSource(new InputStreamReader(actualStream))
		
		XMLUnit.ignoreWhitespace = true
		XMLUnit.ignoreAttributeOrder = true
		val diff = XMLUnit.compareXML(expectedSource, actualSource)
		diff.overrideDifferenceListener(new UMLDefaultValuesDifferenceListener)
		return diff.similar ? FileComparisonResult.CORRECT : FileComparisonResult.INCORRECT_FILE
	}
	
	private static class UMLDefaultValuesDifferenceListener implements DifferenceListener {
		override differenceFound(Difference difference) {
			if (difference.id === DifferenceConstants.ELEMENT_NUM_ATTRIBUTES_ID) {
				// triggers detailed comparison of missing attributes
				return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
			}
			else if (difference.id === DifferenceConstants.ATTR_NAME_NOT_FOUND_ID) {
				if (difference.controlNodeDetail.value == "type") {
					val type = difference.controlNodeDetail.node.attributes.getNamedItem("xmi:type").nodeValue
					val nodeType = difference.controlNodeDetail.node.nodeName
					if ((type == "uml:PackageImport" && nodeType == "packageImport") ||
						(type == "uml:Property" && nodeType == "ownedAttribute") ||
						(type == "uml:Operation" && nodeType == "ownedOperation") ||
						(type == "uml:Parameter" && nodeType == "ownedParameter")
					)
					return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
				}
				else if (difference.controlNodeDetail.value == "visibility") {
					val controlAttributes = difference.controlNodeDetail.node.attributes
					val visibility = controlAttributes.getNamedItem("visibility").nodeValue
					val type = controlAttributes.getNamedItem("xmi:type").nodeValue
					if (visibility == "public" && type == "uml:Class") {
						return DifferenceListener.RETURN_IGNORE_DIFFERENCE_NODES_SIMILAR
					}
				}
			}
			return DifferenceListener.RETURN_ACCEPT_DIFFERENCE
		}
		
		override skippedComparison(Node control, Node test) {
			
		}
	}
}