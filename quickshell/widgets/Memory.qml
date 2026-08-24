import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Memory usage from /proc/meminfo, sampled every 10 seconds (waybar's
// interval). used = total - available, shown as GiB.
BarWidget {
  id: root

  property real usedGib: 0
  property real totalGib: 0

  label: " " + usedGib.toFixed(1) + "G/" + totalGib.toFixed(1) + "G"
  accent: Color.sky

  onClicked: run(["foot", "-e", "btop"])

  Timer {
    interval: 10000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: meminfoFile.reload()
  }

  FileView {
    id: meminfoFile
    path: "/proc/meminfo"
    onLoaded: {
      const values = {}
      for (const line of text().split("\n")) {
        const parts = line.split(/\s+/)
        if (parts.length >= 2)
          values[parts[0].replace(":", "")] = Number(parts[1])
      }

      const total = values.MemTotal || 0
      const available = values.MemAvailable !== undefined
        ? values.MemAvailable
        : values.MemFree || 0

      root.totalGib = total / 1048576
      root.usedGib = (total - available) / 1048576
    }
  }
}
