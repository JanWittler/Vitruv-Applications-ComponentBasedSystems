package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.umljava.tests.uml2java.StateBasedChangeTest
import tools.vitruv.external.applications.external.strategies.StateBasedChangeDiffProviderStorage
import tools.vitruv.external.applications.external.strategies.DiffReplayingStateBasedChangeResolutionStrategy
import tools.vitruv.external.applications.external.strategies.StateBasedChangeDiffProvider
import org.junit.jupiter.api.BeforeEach

abstract class DiffProvidingStateBasedChangeTest extends StateBasedChangeTest {
	val diffProviderLogger = new StateBasedChangeDiffProviderStorage()
	val strategy = new DiffReplayingStateBasedChangeResolutionStrategy(diffProviderLogger)
	
	override getStateBasedResolutionStrategy() { return strategy }
	
	def StateBasedChangeDiffProvider getDiffProvider()
	
	@BeforeEach
	def void setupDiffProvider() {
		diffProviderLogger.reset()
		diffProviderLogger.setDiffProvider(getDiffProvider())
	}
	
	def getDerivedDiffs() {
		return diffProviderLogger.getDiffs()
	}
	
	override logChanges() {
		super.logChanges()
		println('''diffs:
		«getDerivedDiffs()»''')
	}
}