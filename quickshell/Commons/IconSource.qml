pragma Singleton

import QtQuick
import Quickshell

// Resolves a sender-provided notification icon to an Image source. Theme
// icon names go through the shared icon provider; `file://` URLs and
// absolute paths (how Chromium-based browsers pass web-notification
// favicons in app_icon) are loaded directly, because Quickshell.iconPath()
// only understands theme names.
QtObject {
  function resolve(icon) {
    if (!icon)
      return ""
    if (icon.startsWith("file:") || icon.startsWith("/"))
      return icon
    return Quickshell.iconPath(icon, true)
  }
}
