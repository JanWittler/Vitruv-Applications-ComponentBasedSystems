package mir.routines.umlXpcmComponent_L2R;

import java.io.IOException;
import mir.routines.umlXpcmComponent_L2R.RoutinesFacade;
import org.eclipse.uml2.uml.Operation;
import org.eclipse.xtext.xbase.lib.Extension;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class OnRepositoryComponentNameReplacedAtOperation_nameBidirectionalRepairRoutine extends AbstractRepairRoutineRealization {
  private OnRepositoryComponentNameReplacedAtOperation_nameBidirectionalRepairRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final Operation affectedEObject, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.repositoryComponent_BidirectionalCheck(affectedEObject, "updateComponentName");
    }
  }
  
  public OnRepositoryComponentNameReplacedAtOperation_nameBidirectionalRepairRoutine(final RoutinesFacade routinesFacade, final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final Operation affectedEObject) {
    super(routinesFacade, reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.umlXpcmComponent_L2R.OnRepositoryComponentNameReplacedAtOperation_nameBidirectionalRepairRoutine.ActionUserExecution(getExecutionState(), this);
    this.affectedEObject = affectedEObject;
  }
  
  private Operation affectedEObject;
  
  protected boolean executeRoutine() throws IOException {
    getLogger().debug("Called routine OnRepositoryComponentNameReplacedAtOperation_nameBidirectionalRepairRoutine with input:");
    getLogger().debug("   affectedEObject: " + this.affectedEObject);
    
    userExecution.callRoutine1(affectedEObject, this.getRoutinesFacade());
    
    postprocessElements();
    
    return true;
  }
}