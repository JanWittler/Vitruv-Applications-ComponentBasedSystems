package mir.responses.responses5_1ToJava.pcm2javaEjb;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.repository.CollectionDataType;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.Repository;
import tools.vitruv.extensions.dslsruntime.response.AbstractResponseRealization;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;
import tools.vitruv.framework.userinteraction.UserInteracting;

@SuppressWarnings("all")
class DeletedCollectionDataTypeResponse extends AbstractResponseRealization {
  public DeletedCollectionDataTypeResponse(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  private boolean checkTriggerPrecondition(final RemoveEReference<Repository, DataType> change) {
    DataType _oldValue = change.getOldValue();
    return (_oldValue instanceof CollectionDataType);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return RemoveEReference.class;
  }
  
  private boolean checkChangeProperties(final RemoveEReference<Repository, DataType> change) {
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
    if (!(change instanceof RemoveEReference<?, ?>)) {
    	return false;
    }
    RemoveEReference typedChange = (RemoveEReference)change;
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
    RemoveEReference<Repository, DataType> typedChange = (RemoveEReference<Repository, DataType>)change;
    mir.routines.pcm2javaEjb.DeletedCollectionDataTypeEffect effect = new mir.routines.pcm2javaEjb.DeletedCollectionDataTypeEffect(this.executionState, this, typedChange);
    effect.applyRoutine();
  }
}