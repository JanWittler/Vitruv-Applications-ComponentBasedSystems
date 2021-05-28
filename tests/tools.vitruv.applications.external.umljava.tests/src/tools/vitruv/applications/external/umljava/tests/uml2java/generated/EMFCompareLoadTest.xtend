package tools.vitruv.applications.external.umljava.tests.uml2java.generated

import com.google.common.base.Stopwatch
import java.nio.file.Files
import java.nio.file.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation
import org.junit.jupiter.api.Order
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInfo
import org.junit.jupiter.api.TestMethodOrder
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.DeleteReductionSimilarityBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.SimilarityBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.StateBasedDifferencesProvider
import tools.vitruv.applications.external.umljava.tests.util.TimeMeasurement
import tools.vitruv.testutils.TestLogging
import tools.vitruv.testutils.TestProject
import tools.vitruv.testutils.TestProjectManager

import static org.junit.jupiter.api.Assertions.assertTrue

@ExtendWith(TestProjectManager, TestLogging)
@TestMethodOrder(OrderAnnotation)
class EMFCompareLoadTest {
	var Path testProjectFolder
	var TestInfo testInfo
	var ResourceSet resourceSet
	var Resource resource
	var Model model
	
	@BeforeEach
	def void setupResourceSet(@TestProject Path testProjectFolder, TestInfo testInfo) {
		this.testProjectFolder = testProjectFolder
		this.testInfo = testInfo
		
		resourceSet = new ResourceSetImpl
		val resourcePath = Path.of("testresources").resolve("Generated/Large/Base.uml")
		assertTrue(Files.exists(resourcePath), '''please first generate the UML model using UmlModelGenerator#generateLargeModel and place it in «resourcePath»''')
		val copiedPath = testProjectFolder.resolve("Original.uml")
		Files.copy(resourcePath, copiedPath)
		resource = resourceSet.getResource(URI.createFileURI(resourcePath.toFile.absolutePath), true)
		model = resource.contents.head as Model
	}
	
	@Test
	@Order(1)
	def initCache() {
	    val c1 = getClass(#[0], 0)
        val p1 = getPackage(#[1])
        p1.packagedElements += c1
        generateDiffs(new DefaultStateBasedDifferencesProvider)
	}
	
	@ParameterizedTest(name="moveDeepClasses({0})")
	@MethodSource("strategySource")
	def moveDeepClasses(StateBasedDifferencesProvider provider) {
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
		generateDiffs(provider)
	}
	
	@ParameterizedTest(name="moveClasses({0})")
    @MethodSource("strategySource")
	def moveClasses(StateBasedDifferencesProvider provider) {
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
		generateDiffs(provider)
	}
	
	static def strategySource() {
	    return #[new DefaultStateBasedDifferencesProvider, new SimilarityBasedDifferencesProvider, new DeleteReductionSimilarityBasedDifferencesProvider]
	}
	
	def void generateDiffs(StateBasedDifferencesProvider provider) {
		val originalPath = testProjectFolder.resolve("Original.uml")
		val originalResource = resourceSet.getResource(URI.createFileURI(originalPath.toFile.absolutePath), true)
		val stopwatch = Stopwatch.createStarted
		val diffs = provider.getDifferences(resource, originalResource)
		stopwatch.stop
		println(diffs.size)
		TimeMeasurement.shared.startTest(testInfo, provider.class.name)
		TimeMeasurement.shared.addStopwatchForKey(stopwatch, "diff-provider")
		TimeMeasurement.shared.stopAndLogActiveTest()
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