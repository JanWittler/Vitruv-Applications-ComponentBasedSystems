package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.external.applications.external.strategies.BasicStateBasedChangeDiffProvider

class BasicIdBasedTest extends UML2JavaStateBasedChangeTest {
	override getDiffProvider() {
		return new BasicStateBasedChangeDiffProvider()
	}
}