package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.strategies.BasicStateBasedChangeDiffProvider

class BasicIdBasedTest extends Uml2JavaStateBasedChangeTest {
	override getDiffProvider() {
		return new BasicStateBasedChangeDiffProvider()
	}
}