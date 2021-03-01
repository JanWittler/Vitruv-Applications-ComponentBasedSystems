package tools.vitruv.applications.external.umljava.tests.util;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.uml2.uml.internal.resource.UMLResourceFactoryImpl;
import org.eclipse.uml2.uml.resource.UMLResource;

@SuppressWarnings("restriction")
public class UMLResourceWithoutUUIDsFactoryImpl extends UMLResourceFactoryImpl implements UMLResource.Factory {

	/**
	 * Creates an instance of the resource. <!-- begin-user-doc --> <!--
	 * end-user-doc -->
	 * 
	 * @generated
	 */
	public Resource createResourceGen(URI uri) {
		UMLResource result = new UMLResourceImplWithoutUUIDs(uri);
		result.setEncoding(UMLResource.DEFAULT_ENCODING);
		return result;
	}

}
