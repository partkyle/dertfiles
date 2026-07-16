import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets

Scope {
    // ── Catppuccin Mocha palette ──
    readonly property string crust: "#11111b"
    readonly property string base: "#1e1e2e"
    readonly property string surface0: "#313244"
    readonly property string surface1: "#45475a"
    readonly property string overlay0: "#6c7086"
    readonly property string overlay1: "#7f849c"
    readonly property string text: "#cdd6f4"
    readonly property string rosewater: "#f5e0dc"
    readonly property string pink: "#f5c2e7"
    readonly property string mauve: "#cba6f7"
    readonly property string red: "#f38ba8"
    readonly property string maroon: "#eba0ac"
    readonly property string peach: "#fab387"
    readonly property string yellow: "#f9e2af"
    readonly property string green: "#a6e3a1"
    readonly property string sky: "#89dceb"
    readonly property string blue: "#89b4fa"
    readonly property string lavender: "#b4befe"

    // ── State ──
    property string cpuText: "---"
    property string memText: "---"
    property string netText: "---"
    property string volumeText: "---"
    property string batteryText: ""

    // ══ CPU polling ══
    Timer {
        id: cpuTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: { cpuProc.running = true; }
    }
    Process {
        id: cpuProc
        command: ["/bin/sh", "-c",
            "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; " +
            "total=$((user + nice + system + idle + iowait + irq + softirq + steal)); " +
            "used=$((total - idle - iowait)); " +
            "echo \"$((used * 100 / total))%\""]
        running: false
        stdout: StdioCollector {
            onDataChanged: {
                cpuText = text.trim() || "---";
                cpuProc.running = false;
            }
        }
    }

    // ══ Memory polling ══
    Timer {
        id: memTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: { memProc.running = true; }
    }
    Process {
        id: memProc
        command: ["/bin/sh", "-c",
            "total=$(awk '/^MemTotal:/{print $2}' /proc/meminfo); " +
            "avail=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo); " +
            "used=$(( (total - avail) / 1024 )); " +
            "total=$(( total / 1024 )); " +
            "echo \"${used}M/${total}M\""]
        running: false
        stdout: StdioCollector {
            onDataChanged: {
                memText = text.trim() || "---";
                memProc.running = false;
            }
        }
    }

    // ══ Network polling (via shell: works with systemd-networkd) ══
    Timer {
        id: netTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: { netProc.running = true; }
    }
    Process {
        id: netProc
        command: ["/bin/sh", "-c",
            "ip -4 addr show scope global | grep -q 'inet ' && echo 'Connected' || echo 'Offline'"]
        running: false
        stdout: StdioCollector {
            onDataChanged: {
                netText = text.trim() || "Offline";
                netProc.running = false;
            }
        }
    }

    // ══ Audio polling ══
    Timer {
        id: audioTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateAudio()
    }
    function updateAudio() {
        try {
            var sink = Pipewire.defaultAudioSink;
            if (sink && sink.audio) {
                var a = sink.audio;
                if (a.muted) {
                    volumeText = "Muted";
                } else {
                    volumeText = Math.round(a.volume * 100) + "%";
                }
            } else {
                volumeText = "---";
            }
        } catch (e) {
            volumeText = "---";
        }
    }

    // ══ Battery polling ══
    Timer {
        id: batteryTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: updateBattery()
    }
    function updateBattery() {
        try {
            for (var i = 0; i < UPower.devices.length; i++) {
                var dev = UPower.devices[i];
                if (dev.type === 2) { // Battery
                    var pct = Math.round(dev.percentage);
                    batteryText = (dev.state === 1 ? "⚡" : "") + pct + "%";
                    return;
                }
            }
        } catch (e) {}
        batteryText = "";
    }

    // ══ Clock ══
    property string clockText: ""
    Timer {
        id: clockTimer
        interval: 30000
        running: true
        repeat: true
        onTriggered: updateClock()
    }
    function updateClock() {
        var now = new Date();
        var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
        clockText = days[now.getDay()] + " " + now.getDate() + " " +
                    String(now.getHours()).padStart(2,'0') + ":" +
                    String(now.getMinutes()).padStart(2,'0');
    }

    // ══ Click-action processes ══
    Process { id: cpuClickProc; command: ["foot", "-e", "btop"]; running: false }
    Process { id: memClickProc; command: ["foot", "-e", "btop"]; running: false }
    Process { id: netClickProc; command: ["foot", "-e", "iwctl"]; running: false }
    Process { id: audioClickProc; command: ["foot", "-e", "wiremix", "-v", "output"]; running: false }
    Process { id: clockClickProc; command: ["brave", "--app=https://calendar.google.com"]; running: false }

    // ═══════════════════════════════════════════
    // PANEL WINDOW
    // ═══════════════════════════════════════════
    PanelWindow {
        id: bar
        anchors.top: true
        anchors.left: true
        anchors.right: true
        exclusiveZone: 28
        exclusionMode: ExclusionMode.Normal
        aboveWindows: true
        focusable: false

        implicitHeight: 28
        color: crust

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 0

            // Left: system tray
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Repeater {
                    model: SystemTray.items
                    delegate: WrapperMouseArea {
                        id: trayItem
                        implicitWidth: 22
                        implicitHeight: 22
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        IconImage {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            source: modelData.iconName
                        }

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton)
                                modelData.activate(mouse.x, mouse.y);
                            else
                                modelData.contextMenu(mouse.x, mouse.y);
                        }
                    }
                }
            }

            // Right: status widgets
            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 12

                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { cpuClickProc.running = true; }
                    Label {
                        text: "CPU " + cpuText
                        color: peach
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { memClickProc.running = true; }
                    Label {
                        text: "MEM " + memText
                        color: sky
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { netClickProc.running = true; }
                    Label {
                        text: netText
                        color: yellow
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { audioClickProc.running = true; }
                    Label {
                        text: volumeText
                        color: blue
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    visible: batteryText !== ""
                    Label {
                        text: batteryText
                        color: green
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                WrapperMouseArea {
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { clockClickProc.running = true; }
                    Label {
                        text: clockText
                        color: rosewater
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        updateClock();
        updateAudio();
        updateBattery();
    }
}
