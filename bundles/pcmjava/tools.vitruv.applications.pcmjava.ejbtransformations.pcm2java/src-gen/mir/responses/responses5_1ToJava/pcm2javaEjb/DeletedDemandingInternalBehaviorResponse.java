package mir.responses.responses5_1ToJava.pcm2javaEjb;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.repository.BasicComponent;
import org.palladiosimulator.pcm.seff.ResourceDemandingInternalBehaviour;
import tools.vitruv.extensions.dslsruntime.response.AbstractResponseRealization;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;
import tools.vitruv.framework.userinteraction.UserInteracting;

@SuppressWarnings("all")
class DeletedDemandingInternalBehaviorResponse extends AbstractResponseRealization {
  public DeletedDemandingInternalBehaviorResponse(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return RemoveEReference.class;
  }
  
  private boolean checkChangeProperties(final RemoveEReference<BasicComponent, ResourceDemandingInternalBehaviour> change) {
    EObject changedElement = change.getAffectedEObject();
    // Check model element type
    if (!(changedElement instanceof BasicComponent)) {
    	return false;
    }
    
    // Check feature
    if (!change.getAffectedFeature().getName().equals("resourceDemandingInternalBehaviours__BasicComponent")) {
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
    getLogger().debug("Passed precondition check of response " + this.getClass().getName());
    return true;
  }
  
  public void executeResponse(final EChange change) {
    RemoveEReference<BasicComponent, ResourceDemandingInternalBehaviour> typedChange = (RemoveEReference<BasicComponent, ResourceDemandingInternalBehaviour>)change;
    mir.routines.pcm2javaEjb.DeletedDemandingInternalBehaviorEffect effect = new mir.routines.pcm2javaEjb.DeletedDemandingInternalBehaviorEffect(this.executionState, this, typedChange);
    effect.applyRoutine();
  }
}