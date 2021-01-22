package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader
import java.nio.file.Path
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import org.apache.commons.io.FileUtils
import org.custommonkey.xmlunit.Difference
import org.custommonkey.xmlunit.DifferenceConstants
import org.custommonkey.xmlunit.DifferenceListener
import org.custommonkey.xmlunit.XMLUnit
import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.w3c.dom.Node
import org.xml.sax.InputSource

import static org.custommonkey.xmlunit.XMLUnit.*
import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertTrue
import java.io.BufferedReader
import java.io.FileReader

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
	
	@BeforeEach
	def extendTargetModel() {
		enrichJavaModel()
		assertSourceModelEquals(resourcesDirectory.resolve(INITIALMODELNAME + "." + MODELFILEEXTENSION))
		assertTargetModelEquals(resourcesDirectory().resolve("expected_src"))
	}
	
	@Test
	def testAddClass() {
		testModels("AddClass")
	}
	
	@Test
	def testRemoveClass() {
		testModels("RemoveClass")
	}
	
	@Test
	def testRenameClass() {
		testModels("RenameClass")
	}
	
	@Test
	def testMoveClassEasy() {
		testModels("MoveClassEasy")
	}
	
	@Test
	def testMoveClassHard() {
		testModels("MoveClassHard")
	}
	
	@Test
	def testAddAttribute() {
		testModels("AddAttribute")
	}
	
	@Test
	def testRemoveAttribute() {
		testModels("RemoveAttribute")
	}
	
	def void testModels(String directory) {
		val changedModelPath = resourcesDirectory().resolve(directory).resolve("Model.uml")
		resolveChangedState(changedModelPath)
		assertSourceModelEquals(changedModelPath)
		
		val expectedTargetModel = resourcesDirectory().resolve(directory).resolve("expected_src")
		assertTargetModelEquals(expectedTargetModel)
	}
	
	def enrichJavaModel() {
		resourceAt(testProjectFolder.resolve("src/com.example.first/Example.java")).record [
			val jCompilationUnit = contents.head as CompilationUnit
			val jClass = jCompilationUnit.classifiers.head
			val jClassMethod = jClass.members.get(3) as ClassMethod
			
			val jStatement = StatementsFactory.eINSTANCE.createReturn()
			val jBool = LiteralsFactory.eINSTANCE.createBooleanLiteral()
			jBool.value = false
			jStatement.returnValue = jBool
			jClassMethod.statements.add(jStatement)
		]
		propagate
	}
	
	def assertSourceModelEquals(Path expected) {
		val expectedStream = new FileInputStream(expected.toFile)
		val expectedSource = new InputSource(new InputStreamReader(expectedStream))
		val actualStream = new FileInputStream(sourceModelPath.toFile)
		val actualSource = new InputSource(new InputStreamReader(actualStream))
		
		XMLUnit.ignoreWhitespace = true
		XMLUnit.ignoreAttributeOrder = true
		val diff = XMLUnit.compareXML(expectedSource, actualSource)
		diff.overrideDifferenceListener(new UMLDefaultValuesDifferenceListener)
		assertTrue(diff.similar, '''invalid xml model; diff: «diff»''')
	}
	
	static class UMLDefaultValuesDifferenceListener implements DifferenceListener {
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
	
	def assertTargetModelEquals(Path expected) {
		val targetModelFolder = testProjectFolder.resolve("src")
		assertDirectoriesEqual(expected.toFile(), targetModelFolder.toFile())
	}
	
	def void assertDirectoriesEqual(File expected, File actual) {
		val result = internalDirectoriesEqual(expected, actual)
		val incorrectResults = result.filter[_, value | value != FileComparisonResult.CORRECT]
		assertEquals(0, incorrectResults.size, '''got incorrect results for files: «incorrectResults»''')
	}
	
	private def Map<File, Uml2JavaStateBasedChangeTest.FileComparisonResult> internalDirectoriesEqual(File expected, File actual) {
		val visitedFiles = new HashSet<File>()
		val result = new HashMap<File, Uml2JavaStateBasedChangeTest.FileComparisonResult>()
		for (File file: expected.listFiles().filter[f|!f.hidden]) {
			val relativize = expected.toPath().relativize(file.toPath())
			val fileInOther = actual.toPath().resolve(relativize).toFile()
			visitedFiles += fileInOther
			
			if (!fileInOther.exists) {
				result.put(fileInOther, FileComparisonResult.MISSING_FILE)
			}
			else if (!(file.isDirectory == fileInOther.isDirectory)) {
				if (fileInOther.isDirectory) {
					result.put(fileInOther, FileComparisonResult.DIR_INSTEAD_OF_FILE)
				}
				else {
					result.put(fileInOther, FileComparisonResult.FILE_INSTEAD_OF_DIR)
				}
			}
			else if (file.isDirectory) {
				val subResult = internalDirectoriesEqual(file, fileInOther)
				subResult.forEach[key, value | result.put(key, value)]
			}
			else {
				result.put(fileInOther, compareFiles(file, fileInOther))
			}
		}
		for (File file: actual.listFiles().filter[f|!f.hidden]) {
			if (!visitedFiles.contains(file)) {
				result.put(file, FileComparisonResult.FILE_SHOULD_NOT_EXIST)
			}
		}
		return result
	}
	
	private enum FileComparisonResult {
		CORRECT,
		MISSING_FILE,
		DIR_INSTEAD_OF_FILE,
		FILE_INSTEAD_OF_DIR,
		INCORRECT_FILE,
		FILE_SHOULD_NOT_EXIST
	}
	
	def FileComparisonResult compareFiles(File expected, File actual) {
		if (FileUtils.contentEquals(expected, actual)) {
			return FileComparisonResult.CORRECT
		}
		val readerExpected = new BufferedReader(new FileReader(expected))
		val readerActual = new BufferedReader(new FileReader(actual))
		
		var lineExpected = readerExpected.readLineTrimmed
		var lineActual = readerActual.readLineTrimmed
		while (lineExpected !== null || lineActual !== null) {
			//ignore imports as they are currently not cleaned up by the consistency mechanism
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
		reader.readLine?.trim
	}
}