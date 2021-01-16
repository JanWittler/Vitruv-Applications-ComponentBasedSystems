package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.EObject

class ResourceUtil {
	static def copy(Resource resource) {
		val resourceSet = new ResourceSetImpl
		val copy = resourceSet.createResource(resource.URI)
		copy.contents.addAll(EcoreUtil.copyAll(resource.contents))
		copyIDs(resource, copy)
		return copy
	}
	
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
		(destination.eResource() as XMLResource).setID(destination, (source.eResource() as XMLResource).getID(source));
		var i = 0;
		while (i < source.eContents().size() && i < destination.eContents().size) {
			copyIDs(source.eContents().get(i), destination.eContents().get(i))
			i += 1
		}
	}
}