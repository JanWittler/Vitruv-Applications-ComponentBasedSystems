package tools.vitruv.applications.external.strategies

import com.google.common.collect.Lists
import com.google.common.collect.Sets
import java.util.EnumSet
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

class DeleteReductionSimilarityBasedDifferencesProvider implements StateBasedDifferencesProvider {
    enum Option {
        ADJUST_RECURSIVELY, AGGRESSIVE_MERGING
    }
    val EnumSet<Option> options
    val (EObject)=>boolean eObjectFilter

    new() {
        this([true])
    }

    new((EObject)=>boolean eObjectFilter) {
        this(EnumSet.of(Option.ADJUST_RECURSIVELY, Option.AGGRESSIVE_MERGING), eObjectFilter)
    }

    new(EnumSet<Option> options, (EObject)=>boolean eObjectFilter) {
        this.options = options
        this.eObjectFilter = eObjectFilter
    }

    override getDifferences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)

        val registry = EMFCompareRCPPlugin.getDefault.getMatchEngineFactoryRegistry
        val matchEngineFactory = new MatchEngineFactoryImpl(UseIdentifiers.NEVER)
        matchEngineFactory.ranking = 20 // default engine ranking is 10, must be higher to override.
        registry.add(matchEngineFactory)

        val adjustMatchesRecursively = options.contains(Option.ADJUST_RECURSIVELY)
        val mergeLeaves = options.contains(Option.AGGRESSIVE_MERGING)

        val customPostProcessor = new DeleteReductionPostProcessor(adjustMatchesRecursively, mergeLeaves, eObjectFilter)
        val descriptor = new BasicPostProcessorDescriptorImpl(customPostProcessor, Pattern.compile(".*", Pattern.DOTALL), null);

        val postRegistry = new PostProcessorDescriptorRegistryImpl();
        postRegistry.put("CustomPostProcessor", descriptor);

        val comparison = EMFCompare.builder
            .setMatchEngineFactoryRegistry(registry)
            .setPostProcessorRegistry(postRegistry)
            .build
            .compare(scope)
        return comparison.differences
    }

    private static class DeleteReductionPostProcessor implements IPostProcessor {
        val boolean adjustMatchesRecursively
        val boolean mergeLeaves
        val (EObject)=>boolean eObjectFilter

        new(boolean adjustMatchesRecursively, boolean mergeLeaves, (EObject)=>boolean eObjectFilter) {
            this.adjustMatchesRecursively = adjustMatchesRecursively
            this.mergeLeaves = mergeLeaves
            this.eObjectFilter = eObjectFilter
        }

        override postMatch(Comparison comparison, Monitor monitor) {
            adjustMatches(comparison.matches, false)
        }

        private def Iterable<Match> extractAllIncompleteMatches(Iterable<Match> matches) {
            val incompleteMatches = Lists.newLinkedList
            val iterator = matches.iterator
            while (iterator.hasNext) {
                val match = iterator.next
                if (match.left === null || match.right === null) {
                    incompleteMatches += match
                }
                val incompleteSubmatches = match.submatches.extractAllIncompleteMatches
                if (!incompleteSubmatches.empty) {
                    incompleteMatches += incompleteSubmatches
                }
            }
            return incompleteMatches
        }

        private def void adjustMatches(Iterable<Match> matches, boolean mergeLeaves) {
            val incompleteMatches = matches.extractAllIncompleteMatches
            val groupedIncompleteMatches = incompleteMatches.groupBy[left === null]
            val leftMatched = groupedIncompleteMatches.get(false)?.filter[eObjectFilter.apply(left)]
            val rightMatched = groupedIncompleteMatches.get(true)?.filter[eObjectFilter.apply(right)]
            if (leftMatched !== null && rightMatched !== null) {
                adjustMatches(leftMatched, rightMatched, mergeLeaves)
            }
        }

        private def void adjustMatches(Iterable<Match> leftMatched, Iterable<Match> rightMatched, boolean mergeLeaves) {
            var leftUnmatchedEObjects = Sets.newHashSet(rightMatched.map[right])
            var rightUnmatchedMatches = Lists.newLinkedList
            var adjustRecursivelyMatches = Lists.newLinkedList
            for (match: leftMatched) {
                var matched = false
                val submatchContainers = Sets.newHashSet(match.submatches.map [ right?.eContainer ].filterNull)
                if (submatchContainers.size === 1) {
                    val rightEObject = submatchContainers.get(0)
                    val rightMatch = rightMatched.filter[right === rightEObject].head
                    val rightHadSubmatches = !rightMatch?.submatches?.empty
                    if (match.mergeIfMatching(rightMatch)) {
                        if (rightHadSubmatches) {
                            adjustRecursivelyMatches += match
                        }
                        leftUnmatchedEObjects -= rightEObject
                        matched = true
                    }
                }
                if (!matched) {
                    rightUnmatchedMatches += match
                }
            }
            if (mergeLeaves && (leftUnmatchedEObjects.size === 1 && rightUnmatchedMatches.size === 1)) {
                val leftMatch = rightUnmatchedMatches.get(0)
                val rightEObject = leftUnmatchedEObjects.get(0)
                val rightMatch = rightMatched.filter[right === rightEObject].head
                val rightHadSubmatches = !rightMatch?.submatches?.empty
                if (leftMatch.mergeIfMatching(rightMatch)) {
                    if (rightHadSubmatches) {
                        adjustRecursivelyMatches += leftMatch
                    }
                }
            }
            if (adjustMatchesRecursively) {
                adjustRecursivelyMatches.forEach [adjustMatches(submatches, this.mergeLeaves)]
            }
        }

        private def mergeIfMatching(Match mergeIntoLeft, Match mergeFromRight) {
            val left = mergeIntoLeft?.left
            val right = mergeFromRight?.right
            if (left === null || right === null || left.eClass != right.eClass) {
                return false
            }
            mergeIntoLeft.right = mergeFromRight.right
            if (!mergeFromRight.submatches.empty) {
                mergeIntoLeft.submatches += mergeFromRight.submatches
            }
            if (mergeFromRight.eContainer instanceof Match) {
                (mergeFromRight.eContainer as Match).submatches -= mergeFromRight
            }
            return true
        }

        override postComparison(Comparison comparison, Monitor monitor) { }
        override postConflicts(Comparison comparison, Monitor monitor) { }
        override postDiff(Comparison comparison, Monitor monitor) { }
        override postEquivalences(Comparison comparison, Monitor monitor) { }
        override postRequirements(Comparison comparison, Monitor monitor) { }
    }
}