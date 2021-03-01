package tools.vitruv.applications.external.umljava.tests.util

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.XMLResource
import tools.vitruv.framework.domains.repository.DomainAwareResource

/**
 * @author Jan Wittler
 */
class ResourceUtil {
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
