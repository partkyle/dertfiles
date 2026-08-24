import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import qs.Commons
import qs.Ui

// Default output volume via PipeWire (replaces waybar's pulseaudio module).
// Left click opens wiremix, right click mutes, scroll adjusts volume.
BarWidget {
  id: root

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool hasAudio: sink && sink.audio
  readonly property real volume: hasAudio ? sink.audio.volume : 0
  readonly property bool muted: hasAudio ? sink.audio.muted : false

  // Without a tracker the sink's audio properties never populate.
  PwObjectTracker {
    objects: [root.sink]
  }

  function volumeIcon(v) {
    if (v <= 0.001)
      return ""
    if (v < 0.34)
      return ""
    if (v < 0.67)
      return ""
    return ""
  }

  function setVolume(delta) {
    if (!hasAudio)
      return
    sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta))
  }

  label: !hasAudio ? ""
    : muted ? ""
    : volumeIcon(volume) + "  " + Math.round(Math.min(volume, 1) * 100) + "%"
  accent: Color.blue

  onClicked: run(["foot", "-e", "wiremix", "-v", "output"])
  onRightClicked: {
    if (hasAudio)
      sink.audio.muted = !sink.audio.muted
  }
  onScrollUp: setVolume(0.05)
  onScrollDown: setVolume(-0.05)
}
