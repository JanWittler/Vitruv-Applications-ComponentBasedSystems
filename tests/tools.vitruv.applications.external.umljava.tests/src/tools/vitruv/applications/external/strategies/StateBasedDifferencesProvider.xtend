package tools.vitruv.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff

interface StateBasedDifferencesProvider {
    def List<Diff> getDifferences(Notifier newState, Notifier oldState)
}
