package tools.vitruv.applications.external.strategies

import com.google.common.collect.Sets
import java.util.regex.Pattern
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.common.util.Monitor
import org.eclipse.emf.compare.Comparison
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.match.impl.MatchEngineFactoryImpl
import org.eclipse.emf.compare.postprocessor.BasicPostProcessorDescriptorImpl
import org.eclipse.emf.compare.postprocessor.IPostProcessor
import org.eclipse.emf.compare.postprocessor.PostProcessorDescriptorRegistryImpl
import org.eclipse.emf.compare.rcp.EMFCompareRCPPlugin
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.compare.utils.UseIdentifiers
import org.eclipse.emf.common.util.EList

class ReducedDeletionSimilarityBasedDifferencesProvider implements StateBasedDifferencesProvider {
    override getDifferences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)

        val registry = EMFCompareRCPPlugin.getDefault.getMatchEngineFactoryRegistry
        val matchEngineFactory = new MatchEngineFactoryImpl(UseIdentifiers.NEVER)
        matchEngineFactory.ranking = 20 // default engine ranking is 10, must be higher to override.
        registry.add(matchEngineFactory)

        val customPostProcessor = new CustomPostProcessor()
        val descriptor = new BasicPostProcessorDescriptorImpl(customPostProcessor, Pattern.compile("http://www.eclipse.org/uml2/\\d\\.0\\.0/UML"), null);

        val postRegistry = new PostProcessorDescriptorRegistryImpl();
        postRegistry.put("CustomPostProcessor", descriptor);

        val comparison = EMFCompare.builder
            .setMatchEngineFactoryRegistry(registry)
            .setPostProcessorRegistry(postRegistry)
            .build
            .compare(scope)
        return comparison.differences
    }

    static class CustomPostProcessor implements IPostProcessor {
        override postMatch(Comparison comparison, Monitor monitor) {
            comparison.matches.matchUnmatchedRecursively
        }

        private def void matchUnmatchedRecursively(EList<Match> matches) {
            val groupedMatches = matches.groupBy[left === null || right === null]
            val unmatched = groupedMatches.get(true)
            if (unmatched !== null && unmatched.length > 1) {
                val groupedUnmatched = unmatched.groupBy[left === null]
                val leftMatched = groupedUnmatched.get(false)
                val rightMatched = groupedUnmatched.get(true)
                if (leftMatched !== null && rightMatched !== null) {
                    matches.adjustMatches(leftMatched, rightMatched)
                }
            }
            val matched = groupedMatches.get(false)
            matched?.forEach[matchUnmatchedRecursively(submatches)]
        }

        private def void adjustMatches(EList<Match> container, Iterable<Match> leftMatched, Iterable<Match> rightMatched) {
            val leftUnmatchedEObjects = rightMatched.map[right]
            for (match: leftMatched) {
                val submatchContainers = Sets.newHashSet(match.submatches.map [ right?.eContainer ].filterNull)
                if (submatchContainers.size === 1 && leftUnmatchedEObjects.contains(submatchContainers.get(0))) {
                    val matchedRight = submatchContainers.get(0)
                    val unmatchedLeft = rightMatched.filter[right === matchedRight].head
                    container -= unmatchedLeft
                    match.right = matchedRight
                    match.submatches += unmatchedLeft.submatches
                    println("changed match " + match)
                }
            }
        }

        override postComparison(Comparison comparison, Monitor monitor) { }
        override postConflicts(Comparison comparison, Monitor monitor) { }
        override postDiff(Comparison comparison, Monitor monitor) { }
        override postEquivalences(Comparison comparison, Monitor monitor) { }
        override postRequirements(Comparison comparison, Monitor monitor) { }
    }
}