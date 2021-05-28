package tools.vitruv.applications.external.umljava.tests.uml2java.basicsuite

import tools.vitruv.applications.external.strategies.DefaultStateBasedDifferencesProvider
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation
import org.junit.jupiter.api.TestMethodOrder
import org.junit.jupiter.api.Order

@TestMethodOrder(OrderAnnotation)
class DefaultStrategyBasicSuiteTest extends BasicSuiteTest {
    override getDifferencesProvider() {
        return new DefaultStateBasedDifferencesProvider
    }
    
    @Test
    @Order(-1)
    def initCache() {
        testModelInDirectory("AddClass")
    }
}
