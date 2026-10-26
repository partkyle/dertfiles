import QtQuick
import Quickshell

import qs.Commons
import qs.Ui

// Backlight brightness. Left click opens the slider popup (BrightnessPopup)
// under this module; scroll adjusts directly. Hidden on machines without a
// backlight. The popup is a shell-root overlay, so this only reports the
// screen and horizontal offset it should open at.
BarWidget {
  id: root

  // The screen this bar renders on; set by Bar.qml.
  property var screen: null

  readonly property bool available: Brightness.available

  label: !available ? "" : "💡 " + Brightness.percent + "%"
  accent: Colors.yellow

  // Distance from the screen's right edge to this module's right edge, so the
  // popup's right edge lines up with it.
  function rightInset() {
    if (!screen)
      return 0
    return screen.width - root.mapToItem(null, root.width, 0).x
  }

  onClicked: Brightness.openPanel(screen, rightInset())
  onScrollUp: Brightness.setPercent(Brightness.percent + 5)
  onScrollDown: Brightness.setPercent(Brightness.percent - 5)
}
