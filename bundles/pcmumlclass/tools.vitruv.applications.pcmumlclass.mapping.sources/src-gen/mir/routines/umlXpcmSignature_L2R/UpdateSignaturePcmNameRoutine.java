package mir.routines.umlXpcmSignature_L2R;

import java.io.IOException;
import mir.routines.umlXpcmSignature_L2R.RoutinesFacade;
import org.eclipse.uml2.uml.Interface;
import org.eclipse.uml2.uml.Operation;
import org.eclipse.uml2.uml.Parameter;
import org.eclipse.xtext.xbase.lib.Extension;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class UpdateSignaturePcmNameRoutine extends AbstractRepairRoutineRealization {
  private UpdateSignaturePcmNameRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void executeAction1(final Operation operation, final Parameter returnParameter, final Interface interface_, @Extension final RoutinesFacade _routinesFacade) {
    }
  }
  
  public UpdateSignaturePcmNameRoutine(final RoutinesFacade routinesFacade, final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final Operation operation, final Parameter returnParameter, final Interface interface_) {
    super(routinesFacade, reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.umlXpcmSignature_L2R.UpdateSignaturePcmNameRoutine.ActionUserExecution(getExecutionState(), this);
    this.operation = operation;this.returnParameter = returnParameter;this.interface_ = interface_;
  }
  
  private Operation operation;
  
  private Parameter returnParameter;
  
  private Interface interface_;
  
  protected boolean executeRoutine() throws IOException {
    getLogger().debug("Called routine UpdateSignaturePcmNameRoutine with input:");
    getLogger().debug("   operation: " + this.operation);
    getLogger().debug("   returnParameter: " + this.returnParameter);
    getLogger().debug("   interface_: " + this.interface_);
    
    userExecution.executeAction1(operation, returnParameter, interface_, this.getRoutinesFacade());
    
    postprocessElements();
    
    return true;
  }
}
