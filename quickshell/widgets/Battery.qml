import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs.Commons
import qs.Ui

// Battery via UPower (the same service omarchy quatro's battery plugin
// uses). Hidden entirely on machines without a battery (e.g. theseus).
// Warning coloring at 30% / critical at 15%, matching the waybar states.
BarWidget {
  id: root

  readonly property var device: UPower.displayDevice
  readonly property bool present: device && device.isPresent
  readonly property bool onBattery: UPower.onBattery
  readonly property int level: present ? Math.round(device.percentage * 100) : 0
  readonly property bool charging: present && !onBattery

  function batteryIcon() {
    if (charging)
      return ""
    if (level >= 90)
      return ""
    if (level >= 70)
      return ""
    if (level >= 50)
      return ""
    if (level >= 30)
      return ""
    return ""
  }

  readonly property color levelColor: !present ? Color.green
    : onBattery && level <= 15 ? Color.red
    : onBattery && level <= 30 ? Color.peach
    : Color.green

  label: !present ? ""
    : charging
      ? " " + level + "%"
      : batteryIcon() + " " + level + "%"
  accent: levelColor
  labelColor: levelColor
}
