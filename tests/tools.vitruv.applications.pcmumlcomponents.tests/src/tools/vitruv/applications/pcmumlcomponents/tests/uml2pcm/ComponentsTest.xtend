package tools.vitruv.applications.pcmumlcomponents.tests.uml2pcm

import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Interface
import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.OperationInterface
import org.palladiosimulator.pcm.repository.OperationProvidedRole
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.OperationRequiredRole
import org.junit.jupiter.api.Test

import static org.junit.jupiter.api.Assertions.assertNull
import static org.junit.jupiter.api.Assertions.assertTrue
import static org.junit.jupiter.api.Assertions.assertEquals
import static extension edu.kit.ipd.sdq.commons.util.java.lang.IterableUtil.claimOne

class ComponentsTest extends AbstractUmlPcmTest {

	protected static val USAGE_NAME = "testUsage"
	protected static val INTERFACE_REALIZATION_NAME = "testInterfaceRealization"

	protected def Component createUmlComponent(String name, Boolean isComposable) {
		val umlComponent = UMLFactory.eINSTANCE.createComponent()
		umlComponent.name = name
		rootElement.packagedElements += umlComponent
		val componentMode = if(isComposable) 0 else 1
		userInteraction.addNextSingleSelection(componentMode)
		propagate
		return umlComponent
	}

	protected def Component createUmlComponent(String name) {
		createUmlComponent(name, false)
	}

	protected def Interface createUmlInterface(String name) {
		val umlInterface = UMLFactory.eINSTANCE.createInterface()
		umlInterface.name = name
		rootElement.packagedElements += umlInterface
		propagate
		return umlInterface
	}

	protected def CompositeComponent getCorrespondingCompositeComponent(Component umlComponent) {
		getCorrespondingEObjects(umlComponent, CompositeComponent).claimOne
	}

	protected def BasicComponent getCorrespondingBasicComponent(Component umlComponent) {
		getCorrespondingEObjects(umlComponent, BasicComponent).claimOne
	}

	protected def OperationInterface getCorrespondingInterface(Interface umlInterface) {
		getCorrespondingEObjects(umlInterface, OperationInterface).claimOne
	}

	@Test
	def void testCreateBasicComponent() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val correspondingElements = umlComponent.correspondingElements
		assertEquals(1, correspondingElements.length)
		assertTrue(correspondingElements.get(0) instanceof BasicComponent)
		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(umlComponent.name, pcmComponent.entityName)
	}

	@Test
	def void testAddProvidedInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface = createUmlInterface(INTERFACE_NAME)
		val interfaceRealization = UMLFactory.eINSTANCE.createInterfaceRealization()
		interfaceRealization.name = INTERFACE_REALIZATION_NAME
		interfaceRealization.suppliers += umlInterface
		umlComponent.interfaceRealizations += interfaceRealization
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(1, pcmComponent.providedRoles_InterfaceProvidingEntity.length)
		val pcmRole = (pcmComponent.providedRoles_InterfaceProvidingEntity.get(0) as OperationProvidedRole)
		assertEquals(interfaceRealization.name, pcmRole.entityName)
		val pcmInterface = getCorrespondingInterface(umlInterface)
		assertEquals(pcmInterface, pcmRole.providedInterface__OperationProvidedRole)
	}

	@Test
	def void testChangeProvidedInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface1 = createUmlInterface(INTERFACE_NAME)
		val interfaceRealization = UMLFactory.eINSTANCE.createInterfaceRealization()
		interfaceRealization.name = INTERFACE_REALIZATION_NAME
		interfaceRealization.suppliers += umlInterface1
		umlComponent.interfaceRealizations += interfaceRealization
		propagate

		val umlInterface2 = createUmlInterface(INTERFACE_NAME + "2")
		interfaceRealization.suppliers.clear()
		interfaceRealization.suppliers += umlInterface2
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(1, pcmComponent.providedRoles_InterfaceProvidingEntity.length)
		val pcmRole = (pcmComponent.providedRoles_InterfaceProvidingEntity.get(0) as OperationProvidedRole)
		assertEquals(interfaceRealization.name, pcmRole.entityName)
		val pcmInterface = getCorrespondingInterface(umlInterface2)
		assertEquals(pcmInterface, pcmRole.providedInterface__OperationProvidedRole)
	}

	@Test
	def void testRemoveProvidedInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface = createUmlInterface(INTERFACE_NAME)
		val interfaceRealization = UMLFactory.eINSTANCE.createInterfaceRealization()
		interfaceRealization.name = INTERFACE_REALIZATION_NAME
		interfaceRealization.suppliers += umlInterface
		umlComponent.interfaceRealizations += interfaceRealization
		propagate

		umlComponent.interfaceRealizations -= interfaceRealization
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(0, pcmComponent.providedRoles_InterfaceProvidingEntity.length)
	}

	@Test
	def void testAddRequiredInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface = createUmlInterface(INTERFACE_NAME)
		val usage = UMLFactory.eINSTANCE.createUsage()
		usage.name = USAGE_NAME
		usage.suppliers += umlInterface
		umlComponent.packagedElements += usage
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(1, pcmComponent.requiredRoles_InterfaceRequiringEntity.length)
		val pcmRole = (pcmComponent.requiredRoles_InterfaceRequiringEntity.get(0) as OperationRequiredRole)
		assertEquals(usage.name, pcmRole.entityName)
		val pcmInterface = getCorrespondingInterface(umlInterface)
		assertEquals(pcmInterface, pcmRole.requiredInterface__OperationRequiredRole)
	}

	@Test
	def void testChangeRequiredInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface1 = createUmlInterface(INTERFACE_NAME)
		val usage = UMLFactory.eINSTANCE.createUsage()
		usage.name = USAGE_NAME
		usage.suppliers += umlInterface1
		umlComponent.packagedElements += usage
		propagate

		val umlInterface2 = createUmlInterface(INTERFACE_NAME + "2")
		// usage.suppliers.clear()
		// usage.suppliers += #[umlInterface2]
		usage.suppliers.set(0, umlInterface2)
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(1, pcmComponent.requiredRoles_InterfaceRequiringEntity.length)
		val pcmRole = (pcmComponent.requiredRoles_InterfaceRequiringEntity.get(0) as OperationRequiredRole)
		assertEquals(usage.name, pcmRole.entityName)
		val pcmInterface = getCorrespondingInterface(umlInterface2)
		assertEquals(pcmInterface, pcmRole.requiredInterface__OperationRequiredRole)
	}

	@Test
	def void testRemoveRequiredInterface() {
		val umlComponent = createUmlComponent(COMPONENT_NAME)
		val umlInterface = createUmlInterface(INTERFACE_NAME)
		val usage = UMLFactory.eINSTANCE.createUsage()
		usage.name = USAGE_NAME
		usage.suppliers += umlInterface
		umlComponent.packagedElements += usage
		propagate

		umlComponent.packagedElements -= usage
		propagate

		val pcmComponent = getCorrespondingBasicComponent(umlComponent)
		assertEquals(0, pcmComponent.requiredRoles_InterfaceRequiringEntity.length)
	}

	@Test
	def void testCreateCompositeComponent() {
		val umlComponent = createUmlComponent(COMPONENT_NAME, true)
		val correspondingElements = umlComponent.correspondingElements
		assertEquals(1, correspondingElements.length)
		assertTrue(correspondingElements.get(0) instanceof CompositeComponent)
		val pcmComponent = getCorrespondingCompositeComponent(umlComponent)
		assertEquals(umlComponent.name, pcmComponent.entityName)
	}

}
