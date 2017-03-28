package mir.routines.javaToUml;

import java.io.IOException;
import mir.routines.javaToUml.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.uml2.uml.NamedElement;
import org.eclipse.uml2.uml.VisibilityKind;
import org.emftext.language.java.modifiers.AnnotableAndModifiable;
import org.emftext.language.java.modifiers.Modifier;
import tools.vitruv.applications.umljava.java2uml.JavaToUmlHelper;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class ChangeUmlNamedElementVisibilityRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private ChangeUmlNamedElementVisibilityRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final AnnotableAndModifiable jElem, final Modifier mod, final NamedElement uElem) {
      return uElem;
    }
    
    public void update0Element(final AnnotableAndModifiable jElem, final Modifier mod, final NamedElement uElem) {
      VisibilityKind _umlVisibilityKind = JavaToUmlHelper.getUmlVisibilityKind(mod);
      uElem.setVisibility(_umlVisibilityKind);
    }
    
    public EObject getCorrepondenceSourceUElem(final AnnotableAndModifiable jElem, final Modifier mod) {
      return jElem;
    }
  }
  
  public ChangeUmlNamedElementVisibilityRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final AnnotableAndModifiable jElem, final Modifier mod) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.javaToUml.ChangeUmlNamedElementVisibilityRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.javaToUml.RoutinesFacade(getExecutionState(), this);
    this.jElem = jElem;this.mod = mod;
  }
  
  private AnnotableAndModifiable jElem;
  
  private Modifier mod;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine ChangeUmlNamedElementVisibilityRoutine with input:");
    getLogger().debug("   AnnotableAndModifiable: " + this.jElem);
    getLogger().debug("   Modifier: " + this.mod);
    
    NamedElement uElem = getCorrespondingElement(
    	userExecution.getCorrepondenceSourceUElem(jElem, mod), // correspondence source supplier
    	NamedElement.class,
    	(NamedElement _element) -> true, // correspondence precondition checker
    	null);
    if (uElem == null) {
    	return;
    }
    initializeRetrieveElementState(uElem);
    // val updatedElement userExecution.getElement1(jElem, mod, uElem);
    userExecution.update0Element(jElem, mod, uElem);
    
    postprocessElementStates();
  }
}
