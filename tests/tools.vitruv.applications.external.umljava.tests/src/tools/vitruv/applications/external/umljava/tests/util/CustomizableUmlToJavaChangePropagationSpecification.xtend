package tools.vitruv.applications.external.umljava.tests.util

import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
import tools.vitruv.domains.uml.UmlDomain
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy

class CustomizableUmlToJavaChangePropagationSpecification extends UmlToJavaChangePropagationSpecification {
	def setStateBasedChangeResolutionStrategyForUmlDomain(StateBasedChangeResolutionStrategy strategy) {
		(sourceDomain as UmlDomain).stateChangePropagationStrategy = strategy
	}
}