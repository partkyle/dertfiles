import qs.Commons
import qs.Ui

// Volume slider, opened by the bar's audio module. Thin wrapper over the
// shared SliderPopup; Commons/Volume.qml owns the state and writes.
SliderPopup {
  screen: Volume.panelScreen
  open: Volume.panelOpen
  rightMargin: Volume.panelRightMargin
  title: "Volume"
  accent: Colors.blue
  fraction: Volume.fraction
  percent: Volume.percent
  showMute: true
  muted: Volume.muted
  muteLabel: Volume.muted ? "  Unmute" : Volume.volumeIcon(Volume.volume) + "  Mute"
  onPercentRequested: (value) => Volume.setPercent(value)
  onDismissRequested: Volume.closePanel()
  onMuteToggled: Volume.toggleMute()
}
