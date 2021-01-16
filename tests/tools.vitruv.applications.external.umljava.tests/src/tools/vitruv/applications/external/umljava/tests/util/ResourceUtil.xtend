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
	static def copyIDs(Resource source, Resource destination) {
		if (source instanceof XMLResource && destination instanceof XMLResource) {
			var i = 0;
			while (i < source.contents.size && i < destination.contents.size) {
				copyIDs(source.contents.get(i), destination.contents.get(i))
				i += 1
			}
		}
	}
	
	private static def void copyIDs(EObject source, EObject destination) {
		(destination.eResource as XMLResource).setID(destination, (source.eResource as XMLResource).getID(source));
		var i = 0;
		while (i < source.eContents.size() && i < destination.eContents.size) {
			copyIDs(source.eContents.get(i), destination.eContents.get(i))
			i += 1
		}
	}
}