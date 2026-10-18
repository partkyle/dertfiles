pragma Singleton

import QtQuick
import Quickshell.Services.Pipewire

// Default output volume shared by the bar's audio module and its popup.
//
// Pipewire.defaultAudioSink is the source of truth, so mute/volume changes
// from the compositor keys, `wpctl` or any other client update the bar
// immediately. The popup is a shell-root overlay, so this singleton owns its
// open state and the bar module only reports where it should sit.
QtObject {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool hasAudio: sink && sink.audio
  readonly property real volume: hasAudio ? sink.audio.volume : 0
  readonly property bool muted: hasAudio ? sink.audio.muted : false

  // Without a tracker the sink's audio properties never populate.
  readonly property PwObjectTracker tracker: PwObjectTracker {
    objects: [root.sink]
  }

  readonly property real fraction: Math.max(0, Math.min(1, volume))
  readonly property int percent: Math.round(fraction * 100)

  function volumeIcon(v) {
    if (v <= 0.001)
      return ""
    if (v < 0.67)
      return ""
    return ""
  }

  // ── writes ──────────────────────────────────────────────────────────────
  // Setting a non-zero volume always unmutes, matching what the compositor
  // keys and `wpctl set-volume` do: an explicit change means "make a sound".

  function setVolume(value) {
    if (!hasAudio)
      return
    const clamped = Math.max(0, Math.min(1, value))
    sink.audio.volume = clamped
    if (clamped > 0 && sink.audio.muted)
      sink.audio.muted = false
  }

  function setPercent(value) {
    setVolume(value / 100)
  }

  function toggleMute() {
    if (hasAudio)
      sink.audio.muted = !sink.audio.muted
  }

  // ── popup ───────────────────────────────────────────────────────────────
  // The bar module owns none of the popup UI: a single shell-root overlay
  // (VolumePopup.qml) follows whichever screen opened it and is offset so its
  // right edge sits under the module.

  property bool panelOpen: false
  property var panelScreen: null
  property real panelRightMargin: 0

  function openPanel(screen, rightMargin) {
    panelScreen = screen
    panelRightMargin = rightMargin
    panelOpen = true
  }

  function closePanel() {
    panelOpen = false
  }
}
