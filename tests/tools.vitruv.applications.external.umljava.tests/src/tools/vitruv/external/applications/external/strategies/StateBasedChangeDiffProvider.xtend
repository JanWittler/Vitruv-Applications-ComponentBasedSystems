package tools.vitruv.external.applications.external.strategies

import java.util.List
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.emf.compare.Diff

interface StateBasedChangeDiffProvider {
	def List<Diff> getChangeSequences(Notifier newState, Notifier oldState)
}