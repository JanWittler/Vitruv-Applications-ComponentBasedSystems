package tools.vitruv.applications.external.umljava.tests.uml2java

import tools.vitruv.applications.external.umljava.tests.uml2java.StateBasedChangeTest
import org.junit.jupiter.api.BeforeEach
import tools.vitruv.applications.external.strategies.StateBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.TraceableStateBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.DifferencesReplayingStateBasedChangeResolutionStrategy

abstract class StateBasedChangeDifferencesTest extends StateBasedChangeTest {
    protected val traceableDifferencesProvider = new TraceableStateBasedDifferencesProvider()
    val strategy = new DifferencesReplayingStateBasedChangeResolutionStrategy(traceableDifferencesProvider)

    override getStateBasedResolutionStrategy() { return strategy }

    def StateBasedDifferencesProvider getDifferencesProvider()

    @BeforeEach
    def void setupDifferencesProvider() {
        traceableDifferencesProvider.reset()
        traceableDifferencesProvider.differencesProvider = differencesProvider
    }

    def getDerivedDifferences() {
        return traceableDifferencesProvider.differences
    }

    override serializedChanges() {
        super.serializedChanges + "\n" + '''diffs:
        «FOR diff : derivedDifferences»
            «diff»
        «ENDFOR»'''
    }
}
