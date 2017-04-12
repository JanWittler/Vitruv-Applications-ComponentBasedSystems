package mir.routines.pcm2EjbJava;

import java.io.IOException;
import mir.routines.pcm2EjbJava.RoutinesFacade;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.emftext.language.java.members.InterfaceMethod;
import org.emftext.language.java.parameters.OrdinaryParameter;
import org.emftext.language.java.parameters.impl.ParametersFactoryImpl;
import org.emftext.language.java.types.TypeReference;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.OperationSignature;
import org.palladiosimulator.pcm.repository.Parameter;
import tools.vitruv.applications.pcmjava.util.pcm2java.Pcm2JavaHelper;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class CreateParameterRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private CreateParameterRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final Parameter parameter, final InterfaceMethod interfaceMethod, final org.emftext.language.java.classifiers.Class javaParameterTypeClass, final OrdinaryParameter javaParameter) {
      return javaParameter;
    }
    
    public void update0Element(final Parameter parameter, final InterfaceMethod interfaceMethod, final org.emftext.language.java.classifiers.Class javaParameterTypeClass, final OrdinaryParameter javaParameter) {
      EList<org.emftext.language.java.parameters.Parameter> _parameters = interfaceMethod.getParameters();
      _parameters.add(javaParameter);
    }
    
    public EObject getCorrepondenceSourceInterfaceMethod(final Parameter parameter) {
      OperationSignature _operationSignature__Parameter = parameter.getOperationSignature__Parameter();
      return _operationSignature__Parameter;
    }
    
    public EObject getElement2(final Parameter parameter, final InterfaceMethod interfaceMethod, final org.emftext.language.java.classifiers.Class javaParameterTypeClass, final OrdinaryParameter javaParameter) {
      return parameter;
    }
    
    public EObject getElement3(final Parameter parameter, final InterfaceMethod interfaceMethod, final org.emftext.language.java.classifiers.Class javaParameterTypeClass, final OrdinaryParameter javaParameter) {
      return interfaceMethod;
    }
    
    public void updateJavaParameterElement(final Parameter parameter, final InterfaceMethod interfaceMethod, final org.emftext.language.java.classifiers.Class javaParameterTypeClass, final OrdinaryParameter javaParameter) {
      String _parameterName = parameter.getParameterName();
      javaParameter.setName(_parameterName);
      DataType _dataType__Parameter = parameter.getDataType__Parameter();
      final TypeReference parameterTypeReference = Pcm2JavaHelper.createTypeReference(_dataType__Parameter, javaParameterTypeClass);
      javaParameter.setTypeReference(parameterTypeReference);
    }
    
    public EObject getCorrepondenceSourceJavaParameterTypeClass(final Parameter parameter, final InterfaceMethod interfaceMethod) {
      DataType _dataType__Parameter = parameter.getDataType__Parameter();
      return _dataType__Parameter;
    }
  }
  
  public CreateParameterRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final Parameter parameter) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.pcm2EjbJava.CreateParameterRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.pcm2EjbJava.RoutinesFacade(getExecutionState(), this);
    this.parameter = parameter;
  }
  
  private Parameter parameter;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine CreateParameterRoutine with input:");
    getLogger().debug("   Parameter: " + this.parameter);
    
    InterfaceMethod interfaceMethod = getCorrespondingElement(
    	userExecution.getCorrepondenceSourceInterfaceMethod(parameter), // correspondence source supplier
    	InterfaceMethod.class,
    	(InterfaceMethod _element) -> true, // correspondence precondition checker
    	null);
    if (interfaceMethod == null) {
    	return;
    }
    registerObjectUnderModification(interfaceMethod);
    org.emftext.language.java.classifiers.Class javaParameterTypeClass = getCorrespondingElement(
    	userExecution.getCorrepondenceSourceJavaParameterTypeClass(parameter, interfaceMethod), // correspondence source supplier
    	org.emftext.language.java.classifiers.Class.class,
    	(org.emftext.language.java.classifiers.Class _element) -> true, // correspondence precondition checker
    	null);
    registerObjectUnderModification(javaParameterTypeClass);
    OrdinaryParameter javaParameter = ParametersFactoryImpl.eINSTANCE.createOrdinaryParameter();
    userExecution.updateJavaParameterElement(parameter, interfaceMethod, javaParameterTypeClass, javaParameter);
    
    addCorrespondenceBetween(userExecution.getElement1(parameter, interfaceMethod, javaParameterTypeClass, javaParameter), userExecution.getElement2(parameter, interfaceMethod, javaParameterTypeClass, javaParameter), "");
    
    // val updatedElement userExecution.getElement3(parameter, interfaceMethod, javaParameterTypeClass, javaParameter);
    userExecution.update0Element(parameter, interfaceMethod, javaParameterTypeClass, javaParameter);
    
    postprocessElements();
  }
}