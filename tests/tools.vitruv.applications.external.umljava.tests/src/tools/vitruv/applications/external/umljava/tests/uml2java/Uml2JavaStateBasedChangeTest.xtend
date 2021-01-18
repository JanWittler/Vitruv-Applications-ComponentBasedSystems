package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.literals.LiteralsFactory
import org.emftext.language.java.members.ClassMethod
import org.emftext.language.java.statements.StatementsFactory
import org.junit.jupiter.api.Test
import tools.vitruv.applications.external.umljava.tests.util.ResourceUtil
import tools.vitruv.framework.util.datatypes.VURI
import java.io.File
import java.util.HashSet

import static org.junit.jupiter.api.Assertions.assertTrue
import org.apache.commons.io.FileUtils
import org.junit.jupiter.api.BeforeEach

abstract class Uml2JavaStateBasedChangeTest extends DiffProvidingStateBasedChangeTest {
	
	@BeforeEach
	def extendTargetModel() {
		enrichJavaModel()
		assertTargetModelEquals(resourcesDirectory().resolve("expected_src"))
	}
	
	@Test
	def testRename() {
		testModels("Renamed")
	}
	
	def testModels(String directory) {
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
		var visitedFiles = new HashSet<File>()
		for (File file: expected.listFiles().filter[f|!f.hidden]) {
			val relativize = expected.toPath().relativize(file.toPath())
			val fileInOther = actual.toPath().resolve(relativize).toFile()
			visitedFiles += fileInOther
			
			assertTrue(fileInOther.exists, '''[missing file] «fileInOther»''')
			assertTrue(file.isDirectory == fileInOther.isDirectory, '''[«fileInOther.isDirectory ? "dir instead of file" : "file instead of dir"»] «fileInOther»''')
			
			if (file.isDirectory) {
				assertDirectoriesEqual(file, fileInOther)
			}
			else {
				assertTrue(FileUtils.contentEquals(file, fileInOther), '''[incorrect file] «fileInOther»''')
			}
		}
		for (File file: actual.listFiles().filter[f|!f.hidden]) {
			assertTrue(visitedFiles.contains(file), '''[file should not exist] «file»''')
		}
	}
}