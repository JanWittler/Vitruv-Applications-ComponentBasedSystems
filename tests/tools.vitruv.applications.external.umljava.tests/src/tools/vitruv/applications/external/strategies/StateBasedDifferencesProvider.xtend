package tools.vitruv.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff

/** A state based differences provider can compute the difference between two states of a notifier. */
interface StateBasedDifferencesProvider {
    /**
     * Computes the differences between the two given states. They do not need to be based on the same resource.
     * @param newState the new state of the notifier.
     * @param oldState the old state of the notifier.
     * @return Returns the list of differences between the two given states.
     */
    def List<Diff> getDifferences(Notifier newState, Notifier oldState)
}
