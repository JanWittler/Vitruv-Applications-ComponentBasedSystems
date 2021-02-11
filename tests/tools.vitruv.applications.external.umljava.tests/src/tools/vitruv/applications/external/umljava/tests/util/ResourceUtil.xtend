package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.uml2.uml.resource.UMLResource
import tools.vitruv.framework.domains.repository.DomainAwareResource

/**
 * @author Jan Wittler
 */
class ResourceUtil {
	/**
	 * Reloads the given resource.
	 * This helper is necessary since resources provided by the VSUM can not be modified.
	 * @param resource The resource to reload.
	 * @return Returns a new {@link Resource} loaded from the URI of the provided resource.
	 */
	static def reload(Resource resource) {
		val resourceSet = new ResourceSetImpl
		resourceSet.resourceFactoryRegistry.getExtensionToFactoryMap().put(UMLResource::FILE_EXTENSION, new UMLResourceWithoutUUIDsFactoryImpl());
		resourceSet.getResource(resource.URI, true)
	}
	
	/**
	 * Copies the IDs of the resource's elements to the destination.
	 * @param source The resource to get the IDs from.
	 * @param destination The resource to copy the IDs to.
	 */
	static dispatch def void copyIDs(Resource source, Resource destination) {
		
	}
	
	static dispatch def void copyIDs(Resource source, DomainAwareResource destination) {
		copyIDs(source, destination.contents.head?.eResource)
	}
	
	/**
	 * Copies the IDs of the resource's elements to the destination.
	 * @param source The resource to get the IDs from.
	 * @param destination The resource to copy the IDs to.
	 */
	static dispatch def void copyIDs(XMLResource source, XMLResource destination) {
		val sourceIterator = source.allContents
		val destinationIterator = destination.allContents
		while (sourceIterator.hasNext && destinationIterator.hasNext) {
			val sourceObject = sourceIterator.next
			val destinationObject = destinationIterator.next
			destination.setID(destinationObject, source.getID(sourceObject))
		}
	}
}