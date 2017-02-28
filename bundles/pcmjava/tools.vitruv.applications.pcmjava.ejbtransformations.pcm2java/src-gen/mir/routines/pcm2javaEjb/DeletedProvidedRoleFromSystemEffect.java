package mir.routines.pcm2javaEjb;

import java.io.IOException;
import mir.routines.pcm2javaEjb.RoutinesFacade;
import org.eclipse.xtext.xbase.lib.Extension;
import org.palladiosimulator.pcm.repository.ProvidedRole;
import tools.vitruv.extensions.dslsruntime.response.AbstractEffectRealization;
import tools.vitruv.extensions.dslsruntime.response.ResponseExecutionState;
import tools.vitruv.extensions.dslsruntime.response.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;

@SuppressWarnings("all")
public class DeletedProvidedRoleFromSystemEffect extends AbstractEffectRealization {
  public DeletedProvidedRoleFromSystemEffect(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy, final RemoveEReference<org.palladiosimulator.pcm.system.System, ProvidedRole> change) {
    super(responseExecutionState, calledBy);
    				this.change = change;
  }
  
  private RemoveEReference<org.palladiosimulator.pcm.system.System, ProvidedRole> change;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine DeletedProvidedRoleFromSystemEffect with input:");
    getLogger().debug("   RemoveEReference: " + this.change);
    
    
    preprocessElementStates();
    new mir.routines.pcm2javaEjb.DeletedProvidedRoleFromSystemEffect.EffectUserExecution(getExecutionState(), this).executeUserOperations(
    	change);
    postprocessElementStates();
  }
  
  private static class EffectUserExecution extends AbstractEffectRealization.UserExecution {
    @Extension
    private RoutinesFacade effectFacade;
    
    public EffectUserExecution(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy) {
      super(responseExecutionState);
      this.effectFacade = new mir.routines.pcm2javaEjb.RoutinesFacade(responseExecutionState, calledBy);
    }
    
    private void executeUserOperations(final RemoveEReference<org.palladiosimulator.pcm.system.System, ProvidedRole> change) {
      ProvidedRole _oldValue = change.getOldValue();
      this.effectFacade.callRemoveProvidedRole(_oldValue);
    }
  }
}