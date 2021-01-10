package tools.vitruv.applications.external.umljava.tests.util

import tools.vitruv.applications.umljava.UmlToJavaChangePropagationSpecification
import tools.vitruv.framework.domains.VitruvDomain
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy

class CustomizableUmlToJavaChangePropagationSpecification extends UmlToJavaChangePropagationSpecification {
	var VitruvDomain customUmlDomain
	
	override getSourceDomain() {
		return customUmlDomain ?: super.getSourceDomain()
	}
	
	def setStateBasedChangeResolutionStrategyForUmlDomain(StateBasedChangeResolutionStrategy strategy) {
		customUmlDomain = new CustomizableUmlDomain(strategy)
	}
}