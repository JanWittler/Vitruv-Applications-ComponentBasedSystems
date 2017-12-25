package mir.routines.ejbjava2pcm;

import java.io.IOException;
import mir.routines.ejbjava2pcm.RoutinesFacade;
import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.pcm.repository.Repository;
import tools.vitruv.applications.pcmjava.ejbtransformations.java2pcm.EjbJava2PcmHelper;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class CreateRepositoryForFirstPackageRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private CreateRepositoryForFirstPackageRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final org.emftext.language.java.containers.Package javaPackage, final Repository repository) {
      return repository;
    }
    
    public EObject getElement2(final org.emftext.language.java.containers.Package javaPackage, final Repository repository) {
      return javaPackage;
    }
    
    public void updateRepositoryElement(final org.emftext.language.java.containers.Package javaPackage, final Repository repository) {
      repository.setEntityName(javaPackage.getName());
      String _entityName = repository.getEntityName();
      String _plus = ("model/" + _entityName);
      String _plus_1 = (_plus + ".repository");
      this.persistProjectRelative(javaPackage, repository, _plus_1);
    }
    
    public boolean checkMatcherPrecondition1(final org.emftext.language.java.containers.Package javaPackage) {
      Repository _findRepository = EjbJava2PcmHelper.findRepository(this.correspondenceModel);
      boolean _tripleEquals = (_findRepository == null);
      return _tripleEquals;
    }
  }
  
  public CreateRepositoryForFirstPackageRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final org.emftext.language.java.containers.Package javaPackage) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.ejbjava2pcm.CreateRepositoryForFirstPackageRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.ejbjava2pcm.RoutinesFacade(getExecutionState(), this);
    this.javaPackage = javaPackage;
  }
  
  private org.emftext.language.java.containers.Package javaPackage;
  
  protected boolean executeRoutine() throws IOException {
    getLogger().debug("Called routine CreateRepositoryForFirstPackageRoutine with input:");
    getLogger().debug("   javaPackage: " + this.javaPackage);
    
    if (!userExecution.checkMatcherPrecondition1(javaPackage)) {
    	return false;
    }
    org.palladiosimulator.pcm.repository.Repository repository = org.palladiosimulator.pcm.repository.impl.RepositoryFactoryImpl.eINSTANCE.createRepository();
    notifyObjectCreated(repository);
    userExecution.updateRepositoryElement(javaPackage, repository);
    
    addCorrespondenceBetween(userExecution.getElement1(javaPackage, repository), userExecution.getElement2(javaPackage, repository), "");
    
    postprocessElements();
    
    return true;
  }
}
