package mir.responses.responses5_1ToJava.pcm2javaEjb;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.repository.CollectionDataType;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.Repository;
import tools.vitruv.extensions.dslsruntime.response.AbstractResponseRealization;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.feature.reference.InsertEReference;
import tools.vitruv.framework.userinteraction.UserInteracting;

@SuppressWarnings("all")
class CreatedCollectionDataTypeResponse extends AbstractResponseRealization {
  public CreatedCollectionDataTypeResponse(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  private boolean checkTriggerPrecondition(final InsertEReference<Repository, DataType> change) {
    DataType _newValue = change.getNewValue();
    return (_newValue instanceof CollectionDataType);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return InsertEReference.class;
  }
  
  private boolean checkChangeProperties(final InsertEReference<Repository, DataType> change) {
    EObject changedElement = change.getAffectedEObject();
    // Check model element type
    if (!(changedElement instanceof Repository)) {
    	return false;
    }
    
    // Check feature
    if (!change.getAffectedFeature().getName().equals("dataTypes__Repository")) {
    	return false;
    }
    return true;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (!(change instanceof InsertEReference<?, ?>)) {
    	return false;
    }
    InsertEReference typedChange = (InsertEReference)change;
    if (!checkChangeProperties(typedChange)) {
    	return false;
    }
    if (!checkTriggerPrecondition(typedChange)) {
    	return false;
    }
    getLogger().debug("Passed precondition check of response " + this.getClass().getName());
    return true;
  }
  
  public void executeResponse(final EChange change) {
    InsertEReference<Repository, DataType> typedChange = (InsertEReference<Repository, DataType>)change;
    mir.routines.pcm2javaEjb.CreatedCollectionDataTypeEffect effect = new mir.routines.pcm2javaEjb.CreatedCollectionDataTypeEffect(this.executionState, this, typedChange);
    effect.applyRoutine();
  }
}
