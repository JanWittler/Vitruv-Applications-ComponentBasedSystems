package mir.routines.pcm2javaEjb;

import java.io.IOException;
import mir.routines.pcm2javaEjb.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.Extension;
import org.palladiosimulator.pcm.repository.Repository;
import org.palladiosimulator.pcm.repository.RepositoryComponent;
import tools.vitruv.extensions.dslsruntime.response.AbstractEffectRealization;
import tools.vitruv.extensions.dslsruntime.response.ResponseExecutionState;
import tools.vitruv.extensions.dslsruntime.response.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.feature.reference.InsertEReference;

@SuppressWarnings("all")
public class CreatedComponentEffect extends AbstractEffectRealization {
  public CreatedComponentEffect(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy, final InsertEReference<Repository, RepositoryComponent> change) {
    super(responseExecutionState, calledBy);
    				this.change = change;
  }
  
  private InsertEReference<Repository, RepositoryComponent> change;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine CreatedComponentEffect with input:");
    getLogger().debug("   InsertEReference: " + this.change);
    
    org.emftext.language.java.containers.Package repositoryPackage = getCorrespondingElement(
    	getCorrepondenceSourceRepositoryPackage(change), // correspondence source supplier
    	org.emftext.language.java.containers.Package.class,
    	(org.emftext.language.java.containers.Package _element) -> true, // correspondence precondition checker
    	getRetrieveTag0(change));
    if (repositoryPackage == null) {
    	return;
    }
    initializeRetrieveElementState(repositoryPackage);
    
    preprocessElementStates();
    new mir.routines.pcm2javaEjb.CreatedComponentEffect.EffectUserExecution(getExecutionState(), this).executeUserOperations(
    	change, repositoryPackage);
    postprocessElementStates();
  }
  
  private String getRetrieveTag0(final InsertEReference<Repository, RepositoryComponent> change) {
    return "repository_root";
  }
  
  private EObject getCorrepondenceSourceRepositoryPackage(final InsertEReference<Repository, RepositoryComponent> change) {
    RepositoryComponent _newValue = change.getNewValue();
    Repository _repository__RepositoryComponent = _newValue.getRepository__RepositoryComponent();
    return _repository__RepositoryComponent;
  }
  
  private static class EffectUserExecution extends AbstractEffectRealization.UserExecution {
    @Extension
    private RoutinesFacade effectFacade;
    
    public EffectUserExecution(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy) {
      super(responseExecutionState);
      this.effectFacade = new mir.routines.pcm2javaEjb.RoutinesFacade(responseExecutionState, calledBy);
    }
    
    private void executeUserOperations(final InsertEReference<Repository, RepositoryComponent> change, final org.emftext.language.java.containers.Package repositoryPackage) {
      final RepositoryComponent component = change.getNewValue();
      String _entityName = component.getEntityName();
      this.effectFacade.callCreateJavaPackage(component, repositoryPackage, _entityName, null);
      this.effectFacade.callCreateImplementationForComponent(component);
    }
  }
}