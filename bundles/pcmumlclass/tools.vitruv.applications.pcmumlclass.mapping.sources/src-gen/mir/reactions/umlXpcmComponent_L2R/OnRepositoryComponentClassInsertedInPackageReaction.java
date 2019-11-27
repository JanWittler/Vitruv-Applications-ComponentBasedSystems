package mir.reactions.umlXpcmComponent_L2R;

import mir.routines.umlXpcmComponent_L2R.RoutinesFacade;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.xbase.lib.Extension;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractReactionRealization;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.feature.reference.InsertEReference;

@SuppressWarnings("all")
public class OnRepositoryComponentClassInsertedInPackageReaction extends AbstractReactionRealization {
  private InsertEReference<org.eclipse.uml2.uml.Package, org.eclipse.uml2.uml.Class> insertChange;
  
  private int currentlyMatchedChange;
  
  public OnRepositoryComponentClassInsertedInPackageReaction(final RoutinesFacade routinesFacade) {
    super(routinesFacade);
  }
  
  public void executeReaction(final EChange change) {
    if (!checkPrecondition(change)) {
    	return;
    }
    org.eclipse.uml2.uml.Package affectedEObject = insertChange.getAffectedEObject();
    EReference affectedFeature = insertChange.getAffectedFeature();
    org.eclipse.uml2.uml.Class newValue = insertChange.getNewValue();
    int index = insertChange.getIndex();
    				
    getLogger().trace("Passed complete precondition check of Reaction " + this.getClass().getName());
    				
    mir.reactions.umlXpcmComponent_L2R.OnRepositoryComponentClassInsertedInPackageReaction.ActionUserExecution userExecution = new mir.reactions.umlXpcmComponent_L2R.OnRepositoryComponentClassInsertedInPackageReaction.ActionUserExecution(this.executionState, this);
    userExecution.callRoutine1(insertChange, affectedEObject, affectedFeature, newValue, index, this.getRoutinesFacade());
    
    resetChanges();
  }
  
  private void resetChanges() {
    insertChange = null;
    currentlyMatchedChange = 0;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (currentlyMatchedChange == 0) {
    	if (!matchInsertChange(change)) {
    		resetChanges();
    		return false;
    	} else {
    		currentlyMatchedChange++;
    	}
    }
    
    return true;
  }
  
  private boolean matchInsertChange(final EChange change) {
    if (change instanceof InsertEReference<?, ?>) {
    	InsertEReference<org.eclipse.uml2.uml.Package, org.eclipse.uml2.uml.Class> _localTypedChange = (InsertEReference<org.eclipse.uml2.uml.Package, org.eclipse.uml2.uml.Class>) change;
    	if (!(_localTypedChange.getAffectedEObject() instanceof org.eclipse.uml2.uml.Package)) {
    		return false;
    	}
    	if (!_localTypedChange.getAffectedFeature().getName().equals("packagedElement")) {
    		return false;
    	}
    	if (!(_localTypedChange.getNewValue() instanceof org.eclipse.uml2.uml.Class)) {
    		return false;
    	}
    	this.insertChange = (InsertEReference<org.eclipse.uml2.uml.Package, org.eclipse.uml2.uml.Class>) change;
    	return true;
    }
    
    return false;
  }
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final InsertEReference insertChange, final org.eclipse.uml2.uml.Package affectedEObject, final EReference affectedFeature, final org.eclipse.uml2.uml.Class newValue, final int index, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.repositoryComponent_ElementCreatedCheck(affectedEObject);
    }
  }
}