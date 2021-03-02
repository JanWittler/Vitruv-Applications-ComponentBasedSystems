package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import tools.vitruv.framework.domains.repository.DomainAwareResource

/**
 * @author Jan Wittler
 */
class ResourceUtil {
    /**
     * Creates a copy of the given resource in the given resourceSet. 
     * In addition to {@link EcoreUtil#copyAll}, IDs are also copied if present.
     * @param resource The resource to create a copy of.
     * @param resourceSet The resource set in which the copy should be created.
     */
    static def createCopy(Resource resource, ResourceSet resourceSet) {
        val uri = resource.URI
        val copy = resourceSet.resourceFactoryRegistry.getFactory(uri).createResource(uri)
        copy.contents.addAll(EcoreUtil.copyAll(resource.contents))
        copyIDs(resource, copy)
        resourceSet.resources += copy
        return copy
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

    static dispatch def void copyIDs(DomainAwareResource source, Resource destination) {
        copyIDs(source.contents.head?.eResource, destination)
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
