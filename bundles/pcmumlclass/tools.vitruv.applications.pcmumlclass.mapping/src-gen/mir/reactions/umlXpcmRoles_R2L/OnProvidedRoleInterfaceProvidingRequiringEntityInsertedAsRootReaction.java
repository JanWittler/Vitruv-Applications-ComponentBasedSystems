package mir.reactions.umlXpcmRoles_R2L;

import mir.routines.umlXpcmRoles_R2L.RoutinesFacade;
import org.eclipse.xtext.xbase.lib.Extension;
import org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractReactionRealization;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.eobject.CreateEObject;

@SuppressWarnings("all")
public class OnProvidedRoleInterfaceProvidingRequiringEntityInsertedAsRootReaction extends AbstractReactionRealization {
  private CreateEObject<InterfaceProvidingRequiringEntity> createChange;
  
  private int currentlyMatchedChange;
  
  public OnProvidedRoleInterfaceProvidingRequiringEntityInsertedAsRootReaction(final RoutinesFacade routinesFacade) {
    super(routinesFacade);
  }
  
  public void executeReaction(final EChange change) {
    if (!checkPrecondition(change)) {
    	return;
    }
    org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity affectedEObject = createChange.getAffectedEObject();
    				
    getLogger().trace("Passed complete precondition check of Reaction " + this.getClass().getName());
    				
    mir.reactions.umlXpcmRoles_R2L.OnProvidedRoleInterfaceProvidingRequiringEntityInsertedAsRootReaction.ActionUserExecution userExecution = new mir.reactions.umlXpcmRoles_R2L.OnProvidedRoleInterfaceProvidingRequiringEntityInsertedAsRootReaction.ActionUserExecution(this.executionState, this);
    userExecution.callRoutine1(createChange, affectedEObject, this.getRoutinesFacade());
    
    resetChanges();
  }
  
  private void resetChanges() {
    createChange = null;
    currentlyMatchedChange = 0;
  }
  
  private boolean matchCreateChange(final EChange change) {
    if (change instanceof CreateEObject<?>) {
    	CreateEObject<org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity> _localTypedChange = (CreateEObject<org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity>) change;
    	if (!(_localTypedChange.getAffectedEObject() instanceof org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity)) {
    		return false;
    	}
    	this.createChange = (CreateEObject<org.palladiosimulator.pcm.core.entity.InterfaceProvidingRequiringEntity>) change;
    	return true;
    }
    
    return false;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (currentlyMatchedChange == 0) {
    	if (!matchCreateChange(change)) {
    		resetChanges();
    		return false;
    	} else {
    		currentlyMatchedChange++;
    	}
    }
    
    return true;
  }
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final CreateEObject createChange, final InterfaceProvidingRequiringEntity affectedEObject, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.providedRole_ElementCreatedCheck(affectedEObject);
    }
  }
}