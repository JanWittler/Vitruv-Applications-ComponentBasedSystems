package mir.routines.ejbjava2pcm;

import java.io.IOException;
import mir.routines.ejbjava2pcm.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.emftext.language.java.members.Method;
import org.emftext.language.java.types.TypeReference;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.OperationSignature;
import tools.vitruv.applications.pcmjava.util.java2pcm.TypeReferenceCorrespondenceHelper;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class CreatePCMReturnTypeRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private CreatePCMReturnTypeRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final TypeReference returnType, final OperationSignature opSignature, final Method javaMethod) {
      return opSignature;
    }
    
    public void update0Element(final TypeReference returnType, final OperationSignature opSignature, final Method javaMethod) {
      final DataType pcmDataType = TypeReferenceCorrespondenceHelper.getCorrespondingPCMDataTypeForTypeReference(returnType, this.correspondenceModel, this.userInteracting, 
        opSignature.getInterface__OperationSignature().getRepository__Interface(), javaMethod.getArrayDimension());
      opSignature.setReturnType__OperationSignature(pcmDataType);
    }
  }
  
  public CreatePCMReturnTypeRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final TypeReference returnType, final OperationSignature opSignature, final Method javaMethod) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.ejbjava2pcm.CreatePCMReturnTypeRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.ejbjava2pcm.RoutinesFacade(getExecutionState(), this);
    this.returnType = returnType;this.opSignature = opSignature;this.javaMethod = javaMethod;
  }
  
  private TypeReference returnType;
  
  private OperationSignature opSignature;
  
  private Method javaMethod;
  
  protected boolean executeRoutine() throws IOException {
    getLogger().debug("Called routine CreatePCMReturnTypeRoutine with input:");
    getLogger().debug("   returnType: " + this.returnType);
    getLogger().debug("   opSignature: " + this.opSignature);
    getLogger().debug("   javaMethod: " + this.javaMethod);
    
    // val updatedElement userExecution.getElement1(returnType, opSignature, javaMethod);
    userExecution.update0Element(returnType, opSignature, javaMethod);
    
    postprocessElements();
    
    return true;
  }
}
