package mir.routines.umlToPcm;

import java.io.IOException;
import mir.routines.umlToPcm.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.uml2.uml.NamedElement;
import org.palladiosimulator.pcm.repository.CollectionDataType;
import tools.vitruv.applications.pcmumlcomponents.uml2pcm.UmlToPcmTypesUtil;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class RenameElementRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private RenameElementRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement, final CollectionDataType pcmCollectionType) {
      return pcmElement;
    }
    
    public void update0Element(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement, final CollectionDataType pcmCollectionType) {
      if ((pcmElement != null)) {
        String _name = umlElement.getName();
        pcmElement.setEntityName(_name);
      }
    }
    
    public EObject getCorrepondenceSourcePcmElement(final NamedElement umlElement) {
      return umlElement;
    }
    
    public String getRetrieveTag1(final NamedElement umlElement) {
      return "";
    }
    
    public String getRetrieveTag2(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement) {
      return UmlToPcmTypesUtil.COLLECTION_TYPE_TAG;
    }
    
    public EObject getElement2(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement, final CollectionDataType pcmCollectionType) {
      return pcmCollectionType;
    }
    
    public EObject getCorrepondenceSourcePcmCollectionType(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement) {
      return umlElement;
    }
    
    public void update1Element(final NamedElement umlElement, final org.palladiosimulator.pcm.core.entity.NamedElement pcmElement, final CollectionDataType pcmCollectionType) {
      if ((pcmCollectionType != null)) {
        String _name = umlElement.getName();
        String _plus = (_name + UmlToPcmTypesUtil.COLLECTION_TYPE_SUFFIX);
        pcmCollectionType.setEntityName(_plus);
      }
    }
  }
  
  public RenameElementRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final NamedElement umlElement) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.umlToPcm.RenameElementRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.umlToPcm.RoutinesFacade(getExecutionState(), this);
    this.umlElement = umlElement;
  }
  
  private NamedElement umlElement;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine RenameElementRoutine with input:");
    getLogger().debug("   NamedElement: " + this.umlElement);
    
    org.palladiosimulator.pcm.core.entity.NamedElement pcmElement = getCorrespondingElement(
    	userExecution.getCorrepondenceSourcePcmElement(umlElement), // correspondence source supplier
    	org.palladiosimulator.pcm.core.entity.NamedElement.class,
    	(org.palladiosimulator.pcm.core.entity.NamedElement _element) -> true, // correspondence precondition checker
    	userExecution.getRetrieveTag1(umlElement));
    registerObjectUnderModification(pcmElement);
    CollectionDataType pcmCollectionType = getCorrespondingElement(
    	userExecution.getCorrepondenceSourcePcmCollectionType(umlElement, pcmElement), // correspondence source supplier
    	CollectionDataType.class,
    	(CollectionDataType _element) -> true, // correspondence precondition checker
    	userExecution.getRetrieveTag2(umlElement, pcmElement));
    registerObjectUnderModification(pcmCollectionType);
    // val updatedElement userExecution.getElement1(umlElement, pcmElement, pcmCollectionType);
    userExecution.update0Element(umlElement, pcmElement, pcmCollectionType);
    
    // val updatedElement userExecution.getElement2(umlElement, pcmElement, pcmCollectionType);
    userExecution.update1Element(umlElement, pcmElement, pcmCollectionType);
    
    postprocessElements();
  }
}