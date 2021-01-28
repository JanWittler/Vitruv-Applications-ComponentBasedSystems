package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import org.junit.jupiter.api.Test
import tools.vitruv.domains.java.util.JavaPersistenceHelper
import org.emftext.language.java.containers.CompilationUnit

/**
 * A test suite mimicking the exchange tests described in 
 * <a href="https://doi.org/10.1007/s40568-013-0061-x">Model Matching Challenge: Benchmarks for Ecore and BPMN Diagrams</a>.
 * @author Jan Wittler
 */
abstract class ModelMatchChallengeExchangeTest extends Uml2JavaStateBasedChangeTest {
	@Test
	def exchangeElementsTest() {
		testModels("ExchangeElements")
	}
	
	override resourcesDirectory() {
		super.resourcesDirectory().resolve("ModelMatchChallenge/ExchangeElements")
	}
	
	override enrichJavaModel() {
		val javaFilePath1 = testProjectFolder
			.resolve(JavaPersistenceHelper.buildJavaFilePath("DomesticAnimal.java", #["de", "shop"]))
		resourceAt(javaFilePath1).record [
			val jCompilationUnit = contents.head as CompilationUnit
			val jClass = jCompilationUnit.classifiers.head
			val jClassMethod = jClass.members.filter [ name == "setSpecies" ].head
			jClassMethod.name = "changeSpecies"
		]
		propagate
		
		val javaFilePath2 = testProjectFolder
			.resolve(JavaPersistenceHelper.buildJavaFilePath("DomesticAnimalNew.java", #["de", "core"]))
		resourceAt(javaFilePath2).record [
			val jCompilationUnit = contents.head as CompilationUnit
			val jClass = jCompilationUnit.classifiers.head
			val jClassMethod = jClass.members.filter [ name == "setSpecies" ].head
			jClassMethod.name = "adjustSpecies"
		]
		propagate
	}
}