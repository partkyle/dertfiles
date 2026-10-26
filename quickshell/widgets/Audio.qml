import QtQuick

import qs.Commons
import qs.Ui

// Default output volume via PipeWire (replaces waybar's pulseaudio module).
// Left click opens the slider popup (VolumePopup) under this module, middle
// click opens wiremix, right click mutes, scroll adjusts volume.
BarWidget {
  id: root

  // The screen this bar renders on; set by Bar.qml.
  property var screen: null

  readonly property bool hasAudio: Volume.hasAudio

  label: !hasAudio ? ""
    : Volume.muted ? ""
    : Volume.volumeIcon(Volume.volume) + "  " + Volume.percent + "%"
  accent: Colors.blue

  // Distance from the screen's right edge to this module's right edge, so the
  // popup's right edge lines up with it.
  function rightInset() {
    if (!screen)
      return 0
    return screen.width - root.mapToItem(null, root.width, 0).x
  }

  onClicked: Volume.openPanel(screen, rightInset())
  onMiddleClicked: run(["ghostty", "-e", "wiremix", "-v", "output"])
  onRightClicked: Volume.toggleMute()
  onScrollUp: Volume.setVolume(Volume.volume + 0.05)
  onScrollDown: Volume.setVolume(Volume.volume - 0.05)
}
