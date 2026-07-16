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

    property string failText: ""
    property bool lockedOut: false

    // ══ PAM context at root so it's accessible from the surface ══
    PamContext {
        id: pam
        active: true
        config: "quickshell"
        user: "partkyle"

        function onMessage(msg, isError, respReq, respVisible) {
            failText = isError ? msg : "";
            if (isError) failTimer.restart();
        }

        function onCompleted(result) {
            if (result === PamResult.Success) {
                lock.unlock();
            } else if (result === PamResult.MaxTries) {
                lockedOut = true;
                failText = "Too many attempts. Please wait...";
            } else {
                failText = "Authentication failed";
                failTimer.restart();
            }
        }

        function onError(error) {
            failText = "PAM error: " + PamError.toString(error);
            failTimer.restart();
        }
    }

    Timer {
        id: failTimer
        interval: 3000
        onTriggered: { failText = ""; }
    }

    // ══ Session lock ══
    WlSessionLock {
        id: lock
        locked: true

        surface: Component {
            WlSessionLockSurface {
                id: lockSurface
                color: base

                Item {
                    anchors.fill: parent

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
                            text: clockText()

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: { timeLabel.text = clockText() }
                            }
                        }

                        Label {
                            id: dateLabel
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "Maple Mono NF"
                            font.pixelSize: 20
                            color: subtext0
                            text: dateText()

                            Timer {
                                interval: 60000
                                running: true
                                repeat: true
                                onTriggered: { dateLabel.text = dateText() }
                            }
                        }
                    }

                    // Auth section
                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 40
                        spacing: 12
                        width: 300

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

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: pam.message || "Enter password to unlock"
                            font.pixelSize: 13
                            color: pam.messageIsError ? red : subtext0
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: failText
                            font.pixelSize: 12
                            color: red
                            visible: failText !== ""
                        }

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
                                } else if (!pam.responseRequired && text.length > 0) {
                                    // Initial password: start PAM if not started
                                    pam.respond(text);
                                    text = "";
                                }
                            }
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Unlock"
                            flat: false
                            enabled: !lockedOut && passwordField.text.length > 0
                            onClicked: {
                                if (pam.responseRequired || passwordField.text.length > 0) {
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

    // Helper functions for clock/date
    function clockText() {
        var now = new Date();
        return String(now.getHours()).padStart(2,'0') + ":" +
               String(now.getMinutes()).padStart(2,'0');
    }

    function dateText() {
        var now = new Date();
        var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
        var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
        return days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear();
    }
}
