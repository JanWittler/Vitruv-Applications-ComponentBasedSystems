package tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample

import tools.vitruv.applications.external.umljava.tests.uml2java.thesissystemexample.ThesisSystemExampleTest
import tools.vitruv.applications.external.strategies.BasicStateBasedChangeDiffProvider

class BasicIdBasedThesisSystemExampleTest extends ThesisSystemExampleTest {
    override getDiffProvider() {
        new BasicStateBasedChangeDiffProvider
    }
}
