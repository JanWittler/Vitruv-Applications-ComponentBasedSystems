package tools.vitruv.applications.external.strategies

import com.google.common.collect.Lists
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
import org.eclipse.emf.ecore.EObject

class ReducedDeletionSimilarityBasedDifferencesProvider implements StateBasedDifferencesProvider {
    override getDifferences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)

        val registry = EMFCompareRCPPlugin.getDefault.getMatchEngineFactoryRegistry
        val matchEngineFactory = new MatchEngineFactoryImpl(UseIdentifiers.NEVER)
        matchEngineFactory.ranking = 20 // default engine ranking is 10, must be higher to override.
        registry.add(matchEngineFactory)

        val customPostProcessor = new DeleteReductionPostProcessor(false, [eClass.name != "Association"])
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

    static class DeleteReductionPostProcessor implements IPostProcessor {
        val boolean adjustMatchesRecursively
        val (EObject)=>boolean eObjectFilter

        new(boolean adjustMatchesRecursively) {
            this(adjustMatchesRecursively, [true])
        }

        new(boolean adjustMatchesRecursively, (EObject)=>boolean eObjectFilter) {
            this.adjustMatchesRecursively = adjustMatchesRecursively
            this.eObjectFilter = eObjectFilter
        }

        override postMatch(Comparison comparison, Monitor monitor) {
            comparison.adjustMatches(comparison.matches)
        }

        private def Iterable<Match> extractAllIncompleteMatches(Iterable<Match> matches) {
            val incompleteMatches = Lists.newLinkedList
            val iterator = matches.iterator
            while (iterator.hasNext) {
                val match = iterator.next
                if (match.left === null || match.right === null) {
                    incompleteMatches += match
                }
                else {
                    val incompleteSubmatches = match.submatches.extractAllIncompleteMatches
                    if (!incompleteSubmatches.empty) {
                        incompleteMatches += incompleteSubmatches
                    }
                }
            }
            return incompleteMatches
        }

        private def void adjustMatches(Comparison comparison, Iterable<Match> matches) {
            val incompleteMatches = matches.extractAllIncompleteMatches
            val groupedIncompleteMatches = incompleteMatches.groupBy[left === null]
            val leftMatched = groupedIncompleteMatches.get(false)?.filter[eObjectFilter.apply(left)]
            val rightMatched = groupedIncompleteMatches.get(true)?.filter[eObjectFilter.apply(right)]
            if (leftMatched !== null && rightMatched !== null) {
                comparison.adjustMatches(leftMatched, rightMatched)
            }
        }

        private def void adjustMatches(Comparison comparison, Iterable<Match> leftMatched, Iterable<Match> rightMatched) {
            var leftUnmatchedEObjects = Sets.newHashSet(rightMatched.map[right])
            var matchesToProcess = Lists.newLinkedList
            for (match: leftMatched) {
                val submatchContainers = Sets.newHashSet(match.submatches.map [ right?.eContainer ].filterNull)
                if (submatchContainers.size === 1 && leftUnmatchedEObjects.contains(submatchContainers.get(0))) {
                    val rightEObject = submatchContainers.get(0)
                    val rightMatch = rightMatched.filter[right === rightEObject].head
                    match.right = rightEObject
                    if (!rightMatch.submatches.empty) {
                        match.submatches += rightMatch.submatches
                        matchesToProcess += match
                    }
                    if (rightMatch.eContainer instanceof Match) {
                        (rightMatch.eContainer as Match).submatches -= rightMatch
                    }
                    println("changed match " + match)
                    leftUnmatchedEObjects -= rightEObject
                }
            }
            if (adjustMatchesRecursively) {
                matchesToProcess.forEach [comparison.adjustMatches(submatches)]
            }
        }

        override postComparison(Comparison comparison, Monitor monitor) { }
        override postConflicts(Comparison comparison, Monitor monitor) { }
        override postDiff(Comparison comparison, Monitor monitor) { }
        override postEquivalences(Comparison comparison, Monitor monitor) { }
        override postRequirements(Comparison comparison, Monitor monitor) { }
    }
}