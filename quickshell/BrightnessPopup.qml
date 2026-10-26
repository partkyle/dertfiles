import qs.Commons
import qs.Ui

// Brightness slider, opened by the bar's brightness module. Thin wrapper over
// the shared SliderPopup; Commons/Brightness.qml owns the state and writes.
SliderPopup {
  screen: Brightness.panelScreen
  open: Brightness.panelOpen
  rightMargin: Brightness.panelRightMargin
  title: "Brightness"
  accent: Colors.yellow
  fraction: Brightness.fraction
  percent: Brightness.percent
  onPercentRequested: (value) => Brightness.setPercent(value)
  onDismissRequested: Brightness.closePanel()
}
