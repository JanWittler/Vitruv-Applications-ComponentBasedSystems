package tools.vitruv.applications.external.umljava.tests.uml2java.modelmatchchallenge

import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import org.junit.jupiter.api.Test

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
		
	}
}