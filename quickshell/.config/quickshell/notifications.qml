import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

Scope {
    // ── Catppuccin Mocha palette ──
    readonly property string base: "#1e1e2e"
    readonly property string surface0: "#313244"
    readonly property string surface1: "#45475a"
    readonly property string overlay0: "#6c7086"
    readonly property string overlay1: "#7f849c"
    readonly property string text: "#cdd6f4"
    readonly property string subtext0: "#a6adc8"
    readonly property string mauve: "#cba6f7"
    readonly property string red: "#f38ba8"
    readonly property string green: "#a6e3a1"

    NotificationServer {
        id: server
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notif => {
            // Track notification so it appears in trackedNotifications model
            notif.tracked = true;

            // Auto-dismiss non-critical after timeout
            if (notif.expireTimeout > 0 && notif.urgency !== NotificationUrgency.Critical) {
                notif.expireTimer = Qt.createQmlObject(
                    'import QtQuick; Timer { interval: ' + notif.expireTimeout + '; running: true; onTriggered: notifObj.dismiss() }',
                    notif, "expireTimer");
            }

            // Limit to 5 visible
            var count = 0;
            for (var i = 0; i < server.trackedNotifications.length; i++) {
                if (!server.trackedNotifications[i].dismissed) count++;
            }
        }
    }

    // ═══════════════════════════════════════════
    // NOTIFICATION POPUPS
    // ═══════════════════════════════════════════
    Repeater {
        model: server.trackedNotifications

        FloatingWindow {
            id: notifWindow
            required property var modelData
            property bool dismissed: false

            title: "notification"
            color: "transparent"
            visible: !dismissed && !modelData.expired
            minimumSize.width: 350
            minimumSize.height: content.implicitHeight + 24
            maximumSize.width: 350

            // Position in top-right, stacked
            screen: Quickshell.screens[0]
            x: screen ? screen.width - 370 - 10 : 10
            y: 38 + index * 80

            WrapperRectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: base
                border.color: {
                    var ur = modelData.urgency;
                    if (ur === NotificationUrgency.Critical) return red;
                    if (ur === NotificationUrgency.Low) return overlay0;
                    return mauve;
                }
                border.width: 2
                radius: 8

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    // Header row
                    RowLayout {
                        Label {
                            text: modelData.appName || "Notification"
                            font.bold: true
                            font.pixelSize: 13
                            color: mauve
                            Layout.fillWidth: true
                        }
                        WrapperMouseArea {
                            implicitWidth: 20
                            implicitHeight: 20
                            cursorShape: Qt.PointingHandCursor
                            Label {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 14
                                color: overlay1
                            }
                            onClicked: {
                                modelData.dismiss();
                                notifWindow.dismissed = true;
                            }
                        }
                    }

                    // Summary
                    Label {
                        text: modelData.summary || ""
                        font.bold: true
                        font.pixelSize: 14
                        color: text
                        visible: text !== ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    // Body
                    Label {
                        text: modelData.body || ""
                        font.pixelSize: 12
                        color: subtext0
                        visible: text !== ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    // Actions
                    RowLayout {
                        visible: modelData.actions && modelData.actions.length > 0
                        spacing: 6
                        Repeater {
                            model: modelData.actions
                            Button {
                                text: modelData.text || "OK"
                                flat: true
                                onClicked: {
                                    modelData.invoke();
                                    notifWindow.modelData.dismiss();
                                    notifWindow.dismissed = true;
                                }
                            }
                        }
                    }
                }
            }

            // Listen for notification dismissal
            Connections {
                target: modelData
                function onClosed(reason) {
                    notifWindow.dismissed = true;
                }
            }
        }
    }
}
