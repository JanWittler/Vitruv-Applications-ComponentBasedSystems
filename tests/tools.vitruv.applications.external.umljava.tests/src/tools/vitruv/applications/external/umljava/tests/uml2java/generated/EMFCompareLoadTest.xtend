package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import com.google.common.base.Stopwatch
import java.nio.file.Files
import java.nio.file.Path
import java.util.List
import java.util.concurrent.TimeUnit
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager

import static org.junit.jupiter.api.Assertions.assertTrue
import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.StateBasedDifferencesProvider

@ExtendWith(TestProjectManager, TestLogging)
class EMFCompareLoadTest {
	var Path testProjectFolder
	var ResourceSet resourceSet
	var Resource resource
	var Model model
	
	@BeforeEach
	def void setupResourceSet(@TestProject Path testProjectFolder) {
		this.testProjectFolder = testProjectFolder
		
		resourceSet = new ResourceSetImpl
		val resourcePath = Path.of("testresources").resolve("Generated/Large/Base.uml")
		assertTrue(Files.exists(resourcePath), '''please first generate the UML model using UmlModelGenerator#generateLargeModel and place it in «resourcePath»''')
		val copiedPath = testProjectFolder.resolve("Original.uml")
		Files.copy(resourcePath, copiedPath)
		resource = resourceSet.getResource(URI.createFileURI(resourcePath.toFile.absolutePath), true)
		model = resource.contents.head as Model
	}
	
	@Test
	def moveDeepClasses() {
		val c1 = getClass(#[0,0,0,0,0,0,0], 0)
		val c2 = getClass(#[1,1,1,1,1,1,1], 1)
		val c3 = getClass(#[0,0,0,1,1,1], 0)
		val c4 = getClass(#[1,1,1,0,0,0], 1)
		val p1 = getPackage(#[1,0,1,0,1,0,1])
		val p2 = getPackage(#[0,1,0,1,0])
		val p3 = getPackage(#[0,0,1,1])
		val p4 = getPackage(#[0,1,0,1,0,1,0])
		p1.packagedElements += c1
		p2.packagedElements += c2
		p3.packagedElements += c3
		p4.packagedElements += c4
		generateDiffs
	}
	
	@Test
	def moveClasses() {
		val c1 = getClass(#[0,0], 0)
		val c2 = getClass(#[1,1], 1)
		val c3 = getClass(#[0,1,0], 1)
		val c4 = getClass(#[1,0,1], 0)
		val p1 = getPackage(#[1,0])
		val p2 = getPackage(#[0,1])
		val p3 = getPackage(#[0])
		val p4 = getPackage(#[0,1,0,1])
		p1.packagedElements += c1
		p2.packagedElements += c2
		p3.packagedElements += c3
		p4.packagedElements += c4
		generateDiffs
	}
	
	def void generateDiffs() {
		val providers = #[new DefaultStateBasedDifferencesProvider, new SimilarityBasedDifferencesProvider]
		val originalPath = testProjectFolder.resolve("Original.uml")
		val originalResource = resourceSet.getResource(URI.createFileURI(originalPath.toFile.absolutePath), true)
		for (provider : providers) {
			val stopwatch = Stopwatch.createStarted
			val diffs = provider.getDifferences(resource, originalResource)
			stopwatch.stop
			println('''«provider.class.name»: «stopwatch.elapsed(TimeUnit.MILLISECONDS)»ms''')
			printDiffs(diffs, provider)
		}
	}
	
	private def printDiffs(List<Diff> diffs, StateBasedDifferencesProvider provider) {
		println('''diffs from «provider.class.name»:
	«FOR diff: diffs»
	«diff»
«ENDFOR»''')
	}
	
	def getPackage(int[] indexes) {
		var package = model as Package
		for (i : indexes) {
			package = package.packagedElements.filter(Package).get(i)
		}
		return package
	}
	
	def getClass(int[] packageIndexes, int classIndex) {
		val package = getPackage(packageIndexes)
		return package.packagedElements.filter(Class).get(classIndex)
	}
}