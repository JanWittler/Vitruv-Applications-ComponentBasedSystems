package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import tools.vitruv.framework.domains.repository.DomainAwareResource

/**
 * @author Jan Wittler
 */
class ResourceUtil {
	/**
	 * Copies the given resource. 
	 * In contrast to {@link EcoreUtil#copyAll EcoreUtil.copyAll} this method also copies the elements' IDs if there are any.
	 * @param resource The resource to copy.
	 * @return Returns a new {@link Resource} with the contents of the provided resource.
	 */
	static def copy(Resource resource) {
		val resourceSet = new ResourceSetImpl
		resourceSet.resourceFactoryRegistry.getExtensionToFactoryMap().put("uml", new UMLResourceWithoutUUIDsFactoryImpl());
		
//		val copy = resourceSet.createResource(resource.URI)
//		copy.contents.addAll(EcoreUtil.copyAll(resource.contents))
//		copyIDs(resource, copy)
//		copy.save(emptyMap)
		return resourceSet.getResource(resource.URI, true)
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