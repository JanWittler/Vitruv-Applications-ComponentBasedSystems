package tools.vitruv.applications.external.umljava.tests.util;

import org.eclipse.emf.common.util.URI;
import org.eclipse.uml2.uml.internal.resource.UMLResourceImpl;

/**
 * Overwrites {@link UMLResourceImpl} deactivating deprecated resource UUID usage.
 * 
 * @author Heiko Klare
 */
@SuppressWarnings("restriction")
public class UMLResourceImplWithoutUUIDs
		extends UMLResourceImpl {

	public UMLResourceImplWithoutUUIDs(URI uri) {
		super(uri);
	}

	@Override
	protected boolean useUUIDs() {
		return false;
	}

}
