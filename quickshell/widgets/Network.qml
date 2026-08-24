import QtQuick
import Quickshell
import Quickshell.Io

import qs.Commons
import qs.Ui

// Network state from systemd-networkd + iwd (this system doesn't run
// NetworkManager), polled every 5 seconds via scripts/network-status.sh.
// Shows the wifi SSID, "Connected" for ethernet, or "Disconnected".
// Left click opens iwctl in foot, like the waybar config.
BarWidget {
  id: root

  property string kind: "disconnected"
  property string connection: ""

  label: kind === "ethernet" ? "󰈀  Connected"
    : kind === "wifi" ? "  " + connection
    : "󰤮 Disconnected"
  accent: Color.yellow

  onClicked: run(["foot", "-e", "iwctl"])

  function parseLine(line) {
    const trimmed = line.trim()
    if (trimmed.startsWith("wifi\t")) {
      kind = "wifi"
      connection = trimmed.slice(5).trim()
    } else if (trimmed === "ethernet") {
      kind = "ethernet"
      connection = ""
    } else if (trimmed === "disconnected") {
      kind = "disconnected"
      connection = ""
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!netProc.running)
        netProc.running = true
    }
  }

  Process {
    id: netProc
    // bash invocation: works even when the deployed script lost +x
    command: ["bash", Quickshell.shellDir + "/scripts/network-status.sh"]
    stdout: SplitParser {
      onRead: data => root.parseLine(data)
    }
  }
}
