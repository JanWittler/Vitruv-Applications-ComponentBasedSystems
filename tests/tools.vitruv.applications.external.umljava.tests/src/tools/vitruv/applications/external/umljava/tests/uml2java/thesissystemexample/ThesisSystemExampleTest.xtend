package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.umljava.tests.uml2java.Uml2JavaStateBasedChangeTest
import java.nio.file.Path
import org.junit.jupiter.api.Test

/**
 * A test suite mimicking the test described in 
 * <a href="http://ceur-ws.org/Vol-1706/paper6.pdf">Semantic-based Model Matching with EMFCompare</a>.
 * @author Jan Wittler
 */
abstract class ThesisSystemExampleTest extends Uml2JavaStateBasedChangeTest {
    @Test
    def void testThesisSystemExample() {
        testModels("Test1")
    }

    override resourcesDirectory() {
        super.resourcesDirectory.resolve("ThesisSystemExample")
    }

    override preloadModel(Path path) {
        // select ArrayList for all to-many associations
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        userInteraction.addNextSingleSelection(0)
        super.preloadModel(path)
    }

    override enrichJavaModel(Path preloadedModelPath) {
    }
}
