package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UMLResource
import tools.vitruv.framework.tuid.TuidCalculatorAndResolver
import tools.vitruv.domains.uml.tuid.UmlTuidCalculatorAndResolver
import tools.vitruv.framework.domains.AbstractTuidAwareVitruvDomain
import tools.vitruv.framework.domains.StateBasedChangeResolutionStrategy
import tools.vitruv.domains.uml.UmlDomainProvider

class CustomizableUmlDomain extends AbstractTuidAwareVitruvDomain {
	static final String METAMODEL_NAME = "UML"
	public static val NAMESPACE_URIS = UMLPackage.eINSTANCE.nsURIsRecursive
	public static final String FILE_EXTENSION = UMLResource::FILE_EXTENSION
	var shouldTransitivelyPropagateChanges = false
	val StateBasedChangeResolutionStrategy changeResolutionStrategy
	
	new(StateBasedChangeResolutionStrategy strategy) {
		super(METAMODEL_NAME, UMLPackage.eINSTANCE, generateTuidCalculator(), FILE_EXTENSION)
		this.changeResolutionStrategy = strategy
	}
	
	def protected static TuidCalculatorAndResolver generateTuidCalculator() {
		return new UmlTuidCalculatorAndResolver(UMLPackage.eNS_URI)
	}
	
	override registerAtTuidManagement() {
		//TODO: try to reuse the tuid manager of the original UmlDomain
	}

	override getBuilderApplicator() {
		return new UmlDomainProvider().getDomain().getBuilderApplicator()
	}
	
	override shouldTransitivelyPropagateChanges() {
		return shouldTransitivelyPropagateChanges
	}
	
	override getStateChangePropagationStrategy() {
		return changeResolutionStrategy
	}
	
	/**
	 * Calling this methods enable the per default disabled transitive change propagation.
	 * Should only be called for test purposes!
	 */
	def enableTransitiveChangePropagation() {
		shouldTransitivelyPropagateChanges = true
	}
}