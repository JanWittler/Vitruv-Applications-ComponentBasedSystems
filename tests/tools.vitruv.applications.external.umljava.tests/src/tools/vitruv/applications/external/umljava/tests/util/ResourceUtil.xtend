package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.EObject

/**
 * @author Jan Wittler
 */
class ResourceUtil {
	/**
	 * Copies the given resource. 
	 * In contrast to {@link org.eclipse.emf.ecore.util.EcoreUtil#copyAll EcoreUtil.copyAll} this method also copies the elements' IDs if there are any.
	 * @param resource The resource to copy.
	 * @return Returns a new {@link org.eclipse.emf.ecore.resource.Resource Resource} with the contents of the provided resource.
	 */
	static def copy(Resource resource) {
		val resourceSet = new ResourceSetImpl
		val copy = resourceSet.createResource(resource.URI)
		copy.contents.addAll(EcoreUtil.copyAll(resource.contents))
		copyIDs(resource, copy)
		return copy
	}
	
	/**
	 * Copies the IDs of the resource's elements to the destination.
	 * @param source The resource to get the IDs from.
	 * @param destination The resource to copy the IDs to.
	 */
	static dispatch def copyIDs(Resource source, Resource destination) {
		
	}
	
	/**
	 * Copies the IDs of the resource's elements to the destination.
	 * @param source The resource to get the IDs from.
	 * @param destination The resource to copy the IDs to.
	 */
	static dispatch def copyIDs(XMLResource source, XMLResource destination) {
		val sourceIterator = source.allContents
		val destinationIterator = destination.allContents
		while (sourceIterator.hasNext && destinationIterator.hasNext) {
			val sourceObject = sourceIterator.next
			val destinationObject = destinationIterator.next
			destination.setID(destinationObject, source.getID(sourceObject))
		}
	}
}