package tools.vitruv.applications.external.umljava.tests.uml2java

import java.io.File
import java.nio.file.Path
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import org.apache.commons.io.FileUtils
import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.util.datatypes.VURI

import static org.junit.jupiter.api.Assertions.assertEquals

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
	
	@BeforeEach
	def extendTargetModel() {
		enrichJavaModel()
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
		
		val expectedTargetModel = resourcesDirectory().resolve(directory).resolve("expected_src")
		assertTargetModelEquals(expectedTargetModel)
	}
	
	def enrichJavaModel() {
		val jVURI = VURI.getInstance(testProjectFolder.resolve("src/com.example.first/Example.java").toString())
		val jModelInstance = virtualModel.getModelInstance(jVURI)
		val jResource = ResourceUtil.copy(jModelInstance.resource)
		val jCompilationUnit = jResource.contents.head as CompilationUnit
		val jClass = jCompilationUnit.classifiers.head
		val jClassMethod = jClass.members.get(3) as ClassMethod
		startRecordingChanges(jClass)
		
		val jStatement = StatementsFactory.eINSTANCE.createReturn()
		val jBool = LiteralsFactory.eINSTANCE.createBooleanLiteral()
		jBool.value = false
		jStatement.returnValue = jBool
		jClassMethod.statements.add(jStatement)
		        
		saveAndSynchronizeChanges(jClass)
		stopRecordingChanges(jClass)
	}
	
	def assertTargetModelEquals(Path expected) {
		val targetModelFolder = testProjectFolder.resolve("src")
		assertDirectoriesEqual(expected.toFile(), targetModelFolder.toFile())
	}
	
	def void assertDirectoriesEqual(File expected, File actual) {
		val result = internalDirectoriesEqual(expected, actual)
		val incorrectResults = result.filter[_, value | value != TargetModelComparisonResult.CORRECT]
		assertEquals(0, incorrectResults.size, '''got incorrect results for files: «incorrectResults»''')
	}
	
	private def Map<File, TargetModelComparisonResult> internalDirectoriesEqual(File expected, File actual) {
		val visitedFiles = new HashSet<File>()
		val result = new HashMap<File, TargetModelComparisonResult>()
		for (File file: expected.listFiles().filter[f|!f.hidden]) {
			val relativize = expected.toPath().relativize(file.toPath())
			val fileInOther = actual.toPath().resolve(relativize).toFile()
			visitedFiles += fileInOther
			
			if (!fileInOther.exists) {
				result.put(fileInOther, TargetModelComparisonResult.MISSING_FILE)
			}
			else if (!(file.isDirectory == fileInOther.isDirectory)) {
				if (fileInOther.isDirectory) {
					result.put(fileInOther, TargetModelComparisonResult.DIR_INSTEAD_OF_FILE)
				}
				else {
					result.put(fileInOther, TargetModelComparisonResult.FILE_INSTEAD_OF_DIR)
				}
			}
			else if (file.isDirectory) {
				val subResult = internalDirectoriesEqual(file, fileInOther)
				subResult.forEach[key, value | result.put(key, value)]
			}
			else {
				if (FileUtils.contentEquals(file, fileInOther)) {
					result.put(fileInOther, TargetModelComparisonResult.CORRECT)
				}
				else {
					result.put(fileInOther, TargetModelComparisonResult.INCORRECT_FILE)
				}
			}
		}
		for (File file: actual.listFiles().filter[f|!f.hidden]) {
			if (!visitedFiles.contains(file)) {
				result.put(file, TargetModelComparisonResult.FILE_SHOULD_NOT_EXIST)
			}
		}
		return result
	}
	
	private enum TargetModelComparisonResult {
		CORRECT,
		MISSING_FILE,
		DIR_INSTEAD_OF_FILE,
		FILE_INSTEAD_OF_DIR,
		INCORRECT_FILE,
		FILE_SHOULD_NOT_EXIST
	}
}