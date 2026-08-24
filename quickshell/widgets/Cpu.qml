import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// CPU usage from /proc/stat, sampled every 5 seconds (waybar's interval).
BarWidget {
  id: root

  property real lastTotal: 0
  property real lastIdle: 0
  property real usage: 0

  label: " " + Math.round(usage) + "%"
  accent: Color.peach

  onClicked: run(["foot", "-e", "btop"])

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: statFile.reload()
  }

  FileView {
    id: statFile
    path: "/proc/stat"
    onLoaded: {
      const fields = text()
        .split("\n")[0]
        .split(/\s+/)
        .slice(1)
        .map(Number)
        .filter(n => !isNaN(n))
      if (fields.length < 4)
        return

      // idle + iowait
      const idle = fields[3] + (fields[4] || 0)
      const total = fields.reduce((sum, n) => sum + n, 0)

      const dTotal = total - root.lastTotal
      const dIdle = idle - root.lastIdle
      if (root.lastTotal > 0 && dTotal > 0)
        root.usage = (1 - dIdle / dTotal) * 100

      root.lastTotal = total
      root.lastIdle = idle
    }
  }
}
