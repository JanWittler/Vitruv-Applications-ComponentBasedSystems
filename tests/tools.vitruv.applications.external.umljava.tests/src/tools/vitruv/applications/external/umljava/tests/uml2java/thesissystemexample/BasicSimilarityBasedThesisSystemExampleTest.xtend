package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample.ThesisSystemExampleTest
import tools.vitruv.applications.external.strategies.BasicSimilarityBasedStateBasedChangeDiffProvider

class BasicSimilarityBasedThesisSystemExampleTest extends ThesisSystemExampleTest {
    override getDiffProvider() {
        new BasicSimilarityBasedStateBasedChangeDiffProvider
    }
}
