import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Widgets

Scope {
    // ── Catppuccin Mocha palette ──
    readonly property string base: "#1e1e2e"
    readonly property string surface0: "#313244"
    readonly property string surface1: "#45475a"
    readonly property string overlay1: "#7f849c"
    readonly property string text: "#cdd6f4"
    readonly property string subtext0: "#a6adc8"
    readonly property string mauve: "#cba6f7"
    readonly property string red: "#f38ba8"
    readonly property string green: "#a6e3a1"
    readonly property string yellow: "#f9e2af"
    readonly property string rosewater: "#f5e0dc"

    property string failText: ""
    property bool lockedOut: false

    WlSessionLock {
        id: lock
        locked: true

        surface: Component {
            WlSessionLockSurface {
                id: lockSurface
                color: base

                Item {
                    anchors.fill: parent

                    // Background
                    Rectangle {
                        anchors.fill: parent
                        color: base
                    }

                    // Clock + date
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -100
                        spacing: 8

                        Label {
                            id: timeLabel
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "Maple Mono NF"
                            font.pixelSize: 72
                            font.bold: true
                            color: text
                            text: ""

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: {
                                    var now = new Date();
                                    timeLabel.text = String(now.getHours()).padStart(2,'0') + ":" +
                                                     String(now.getMinutes()).padStart(2,'0');
                                }
                            }
                        }

                        Label {
                            id: dateLabel
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "Maple Mono NF"
                            font.pixelSize: 20
                            color: subtext0
                            text: ""
                        }

                        Timer {
                            interval: 60000
                            running: true
                            repeat: true
                            onTriggered: {
                                var now = new Date();
                                var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
                                var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
                                dateLabel.text = days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear();
                            }
                        }
                    }

                    // Auth section
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 40
                        spacing: 12
                        width: 300

                        // Avatar circle
                        WrapperRectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 80
                            implicitHeight: 80
                            radius: 40
                            color: surface0
                            border.color: mauve
                            border.width: 2
                            Label {
                                anchors.centerIn: parent
                                text: "🔒"
                                font.pixelSize: 36
                            }
                        }

                        // Prompt
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: pam.message || "Enter password to unlock"
                            font.pixelSize: 13
                            color: pam.messageIsError ? red : subtext0
                        }

                        // Failure text
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: failText
                            font.pixelSize: 12
                            color: red
                            visible: failText !== ""
                        }

                        // Password field
                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                            focus: !lockedOut
                            enabled: !lockedOut
                            placeholderText: pam.responseRequired ? "Response" : "Password"
                            font.pixelSize: 16
                            horizontalAlignment: TextInput.AlignHCenter
                            color: text
                            background: WrapperRectangle {
                                color: surface0
                                border.color: passwordField.activeFocus ? mauve : surface1
                                border.width: 2
                                radius: 8
                            }
                            onAccepted: {
                                if (pam.responseRequired && text.length > 0) {
                                    pam.respond(text);
                                    text = "";
                                }
                            }
                        }

                        // Unlock button
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Unlock"
                            flat: false
                            enabled: !lockedOut && passwordField.text.length > 0
                            onClicked: {
                                if (pam.responseRequired) {
                                    pam.respond(passwordField.text);
                                }
                                passwordField.text = "";
                            }
                        }
                    }
                }
            }
        }
    }

    // ══ PAM authentication ══
    PamContext {
        id: pam
        active: true
        config: "quickshell" // Uses /etc/pam.d/quickshell
        user: "partkyle"

        onMessage: (msg, isError, respReq, respVisible) => {
            if (isError) {
                failText = msg;
                failTimer.start();
            }
            passwordField.text = "";
            passwordField.focus = true;
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                lock.unlock();
            } else if (result === PamResult.MaxTries) {
                lockedOut = true;
                failText = "Too many attempts. Please wait...";
            } else {
                failText = "Authentication failed";
                failTimer.start();
                passwordField.text = "";
                passwordField.focus = true;
            }
        }

        onError: error => {
            failText = "PAM error: " + PamError.toString(error);
            failTimer.start();
        }
    }

    Timer {
        id: failTimer
        interval: 3000
        onTriggered: { failText = ""; }
    }

    Component.onCompleted: {
        // Trigger initial clock/date
        var now = new Date();
        timeLabel.text = String(now.getHours()).padStart(2,'0') + ":" +
                         String(now.getMinutes()).padStart(2,'0');
        var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
        var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
        dateLabel.text = days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear();
    }
}
