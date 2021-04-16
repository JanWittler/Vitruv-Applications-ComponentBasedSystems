package tools.vitruv.applications.external.strategies

import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.match.impl.MatchEngineFactoryImpl
import org.eclipse.emf.compare.rcp.EMFCompareRCPPlugin
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.compare.utils.UseIdentifiers

/** 
 * A difference provider using always the EMF Compare similarity measure.
 * This implies that IDs are never used for matching with this differences provider.
 */
class SimilarityBasedDifferencesProvider implements StateBasedDifferencesProvider {
    override getDifferences(Notifier newState, Notifier oldState) {
        val scope = new DefaultComparisonScope(newState, oldState, null)

        val registry = EMFCompareRCPPlugin.getDefault.getMatchEngineFactoryRegistry
        val matchEngineFactory = new MatchEngineFactoryImpl(UseIdentifiers.NEVER)
        matchEngineFactory.ranking = 20 // default engine ranking is 10, must be higher to override.
        registry.add(matchEngineFactory)

        val comparison = EMFCompare.builder.setMatchEngineFactoryRegistry(registry).build.compare(scope)
        return comparison.differences
    }
}
