import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Root filesystem usage from `df`, sampled every 30 seconds (waybar's disk
// interval). Shows df's own Use%, so it matches `df -h /`; left click opens
// btop like the CPU and memory modules.
BarWidget {
  id: root

  property int percent: 0

  label: "󰋊 " + percent + "%"
  accent: Colors.lavender

  onClicked: run(["ghostty", "-e", "btop"])

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!dfProc.running)
        dfProc.running = true
    }
  }

  Process {
    id: dfProc
    // -P guarantees one line per filesystem, so a device name containing
    // spaces cannot shift the columns. Capacity is the fifth field.
    command: ["df", "-P", "-B1", "/"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")
        if (lines.length < 2)
          return
        const fields = lines[1].trim().split(/\s+/)
        const capacity = parseInt(fields[4], 10)
        if (!isNaN(capacity))
          root.percent = capacity
      }
    }
  }
}
