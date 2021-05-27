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

/**
 * A custom provider that extends the strategy of the {@link SimilarityBasedDifferencesProvider} with heuristics to reduce delete operations.
 * Deletions are especially costly in model consistency preservation, as the deletion may remove additional information in the target model which cannot be restored.
 * A common pattern with similarity-based strategies is that rename operations are not detected as a change of the name attribute, but rather as a deletion and re-insertion of the container and a move of all descendants.
 * Similar, movement operations are detected as a deletion and re-insertion of the container at the new location and a subsequent movement of all descendants.
 * This provider changes this behavior to favor rename over delete and insert.
 */
class DeleteReductionSimilarityBasedDifferencesProvider implements StateBasedDifferencesProvider {
    /** Options to customize the behavior of the differences provider. */
    enum Option {
        /** If aggressive merging is on, a single left and single right leaf of the same match container are matched if their <code>eClasses</code> match. */
        AGGRESSIVE_MERGING
    }

    val EnumSet<Option> options
    val (EObject)=>boolean eObjectFilter

    /** Initializes the provider with the {@link Option.AGGRESSIVE_MERGING} option enabled and an always-passing <code>eObjectFilter</code>. */
    new() {
        this([true])
    }

    /**
     * Initializes the provider with the {@link Option.AGGRESSIVE_MERGING} option enabled and the provided filter.
     * @param eObjectFilter A filter to optionally exclude certain elements from the delete reduction heuristic. The excluded objects are processed like in a similarity-based strategy.
     */
    new((EObject)=>boolean eObjectFilter) {
        this(EnumSet.of(Option.AGGRESSIVE_MERGING), eObjectFilter)
    }

    /**
     * Initializes the provider with the provided configuration.
     * @param options The options to use with this provider.
     * @param eObjectFilter A filter to optionally exclude certain elements from the delete reduction heuristic. The excluded objects are processed like in a similarity-based strategy.
     */
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

        val mergeSingleLeaves = options.contains(Option.AGGRESSIVE_MERGING)

        val customPostProcessor = new DeleteReductionPostProcessor(mergeSingleLeaves, eObjectFilter)
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

    /** 
     * A custom post-processor to include in the EMF pipeline.
     * This processor tries to reduce the amount of delete operations by adding additional matches.
     * By default, all unmatched objects whose children are all matched to objects with the same container are matched to that container.
     * If <code>mergeSingleLeaves</code> is on, objects without ancestors are merged if there is exactly one other unmatched leaf of the same <code>eClass</code> in their container.
     * */
    private static class DeleteReductionPostProcessor implements IPostProcessor {
        val boolean mergeSingleLeaves
        val (EObject)=>boolean eObjectFilter

        new(boolean mergeSingleLeaves, (EObject)=>boolean eObjectFilter) {
            this.mergeSingleLeaves = mergeSingleLeaves
            this.eObjectFilter = eObjectFilter
        }

        override postMatch(Comparison comparison, Monitor monitor) {
            adjustMatches(comparison.matches)
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

        private def void adjustMatches(Iterable<Match> matches) {
            val incompleteMatches = matches.extractAllIncompleteMatches
            val groupedIncompleteMatches = incompleteMatches.groupBy[left === null]
            val leftMatched = groupedIncompleteMatches.get(false)?.filter[eObjectFilter.apply(left)]
            val rightMatched = groupedIncompleteMatches.get(true)?.filter[eObjectFilter.apply(right)]
            if (leftMatched !== null && rightMatched !== null) {
                adjustMatches(leftMatched, rightMatched)
            }
        }

        private def void adjustMatches(Iterable<Match> leftMatched, Iterable<Match> rightMatched) {
            val leftMatchedLeaves = Lists.newLinkedList
            for (match: leftMatched) {
                if (match.submatches.empty) {
                    leftMatchedLeaves += match
                }
                else {
                    val submatchContainers = Sets.newHashSet(match.submatches.map [ right?.eContainer ].filterNull)
                    if (submatchContainers.size === 1) {
                        val rightMatch = rightMatched.filter[right === submatchContainers.get(0)].head
                        match.mergeIfMatching(rightMatch)
                    }
                }
            }

            if (mergeSingleLeaves) {
                for (match: leftMatchedLeaves) {
                    if (match.eContainer instanceof Match) {
                        val containerLeaves = (match.eContainer as Match).submatches.filter [submatches.empty]
                        val containerLeftMatchedLeaves = containerLeaves
                            .filter [left !== null && right === null]
                            .filter [left.eClass == match.left.eClass]
                        val containerRightMatchedLeaves = containerLeaves
                            .filter [left === null && right !== null]
                            .filter [right.eClass == match.left.eClass]
                        if (containerLeftMatchedLeaves.size == 1 && containerRightMatchedLeaves.size == 1) {
                            match.mergeIfMatching(containerRightMatchedLeaves.get(0))
                        }
                    }
                }
            }
        }

        /**
         * Merges the <code>mergeFromRight</code> into the <code>mergeIntoLeft</code> match if their <code>eClasses</code> match.
         * If the merging is performed, the merged object is deleted from its container.
         */
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