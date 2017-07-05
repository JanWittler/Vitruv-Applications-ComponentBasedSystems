package mir.routines.umlToJavaAttribute;

import java.io.IOException;
import mir.routines.umlToJavaAttribute.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.uml2.uml.Property;
import org.eclipse.xtext.xbase.lib.Extension;
import org.emftext.language.java.members.Field;
import tools.vitruv.applications.umljava.util.java.JavaMemberAndParameterUtil;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class RenameJavaAttributeRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private RenameJavaAttributeRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getCorrepondenceSourceJAttribute(final String oldName, final String newName, final Property uAttribute) {
      return uAttribute;
    }
    
    public void callRoutine1(final String oldName, final String newName, final Property uAttribute, final Field jAttribute, @Extension final RoutinesFacade _routinesFacade) {
      String _name = uAttribute.getName();
      jAttribute.setName(_name);
      JavaMemberAndParameterUtil.renameGettersOfAttribute(jAttribute, oldName);
      JavaMemberAndParameterUtil.renameSettersOfAttribute(jAttribute, oldName);
    }
  }
  
  public RenameJavaAttributeRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final String oldName, final String newName, final Property uAttribute) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.umlToJavaAttribute.RenameJavaAttributeRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.umlToJavaAttribute.RoutinesFacade(getExecutionState(), this);
    this.oldName = oldName;this.newName = newName;this.uAttribute = uAttribute;
  }
  
  private String oldName;
  
  private String newName;
  
  private Property uAttribute;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine RenameJavaAttributeRoutine with input:");
    getLogger().debug("   String: " + this.oldName);
    getLogger().debug("   String: " + this.newName);
    getLogger().debug("   Property: " + this.uAttribute);
    
    Field jAttribute = getCorrespondingElement(
    	userExecution.getCorrepondenceSourceJAttribute(oldName, newName, uAttribute), // correspondence source supplier
    	Field.class,
    	(Field _element) -> true, // correspondence precondition checker
    	null);
    if (jAttribute == null) {
    	return;
    }
    registerObjectUnderModification(jAttribute);
    userExecution.callRoutine1(oldName, newName, uAttribute, jAttribute, actionsFacade);
    
    postprocessElements();
  }
}
