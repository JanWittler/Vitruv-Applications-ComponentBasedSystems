package edu.kit.ipd.sdq.vitruvius.casestudies.pcmjava.transformations.java2pcm

import de.uka.ipd.sdq.pcm.repository.RepositoryFactory
import edu.kit.ipd.sdq.vitruvius.framework.run.transformationexecuter.EmptyEObjectMappingTransformation
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EObject
import org.emftext.language.java.parameters.Parameter

class ParameterMappingTransformation extends EmptyEObjectMappingTransformation {

	override getClassOfMappedEObject() {
		Parameter
	}

	override setCorrespondenceForFeatures() {
		JaMoPP2PCMUtils.addName2EntityNameCorrespondence(featureCorrespondenceMap)
	}

	override updateSingleValuedEAttribute(EObject affectedEObject, EAttribute affectedAttribute, Object oldValue,
		Object newValue) {
		JaMoPP2PCMUtils.updateNameAsSingleValuedEAttribute(affectedEObject, affectedAttribute, oldValue, newValue,
			featureCorrespondenceMap, correspondenceInstance)
	}

	/**
	 * called when a parameter has been created
	 */
	override createEObject(EObject eObject) {
		var jaMoPPParam = eObject as Parameter
		val pcmParameter = RepositoryFactory.eINSTANCE.createParameter
		pcmParameter.dataType__Parameter = TypeReferenceCorrespondenceHelper.
			getCorrespondingPCMDataTypeForTypeReference(jaMoPPParam.typeReference, correspondenceInstance,
				userInteracting, null, null)
		pcmParameter.entityName = jaMoPPParam.name
		return pcmParameter.toArray
	}

	/**
	 * called when a parameter type has been changed
	 */
	 override removeEObject(EObject eObject){
	 	return correspondenceInstance.getAllCorrespondingEObjects(eObject) 
	 }
}