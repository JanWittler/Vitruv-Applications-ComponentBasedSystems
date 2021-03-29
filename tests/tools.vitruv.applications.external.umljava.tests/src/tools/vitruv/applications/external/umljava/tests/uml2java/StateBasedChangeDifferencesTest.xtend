package tools.vitruv.applications.external.umljava.tests.uml2java

import java.nio.file.Path
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.TestInfo
import tools.vitruv.applications.external.strategies.DifferencesReplayingStateBasedChangeResolutionStrategy
import tools.vitruv.applications.external.strategies.StateBasedDifferencesProvider
import tools.vitruv.applications.external.strategies.TraceableStateBasedDifferencesProvider
import tools.vitruv.testutils.TestProject
import tools.vitruv.domains.uml.UmlDomainProvider

/**
 * Extends the basic test class with automatic handling for setting up and handling the differences provider.
 * 
 * @author Jan Wittler
 */
abstract class StateBasedChangeDifferencesTest extends StateBasedChangeTest {
    protected val traceableDifferencesProvider = new TraceableStateBasedDifferencesProvider()
    val strategy = new DifferencesReplayingStateBasedChangeResolutionStrategy(traceableDifferencesProvider, #{new UmlDomainProvider().domain})

    override getStateBasedResolutionStrategy() { return strategy }

    def StateBasedDifferencesProvider getDifferencesProvider()

    @BeforeEach
    def void setupDifferencesProvider() {
        traceableDifferencesProvider.differencesProvider = differencesProvider
    }

    @BeforeEach
    protected override setup(@TestProject Path testProjectFolder, TestInfo testInfo) {
        super.setup(testProjectFolder, testInfo)
        traceableDifferencesProvider.reset()
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
