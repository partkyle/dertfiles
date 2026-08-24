import QtQuick
import Quickshell

import qs.Commons
import qs.Ui

// Clock: 12-hour time with AM/PM like the waybar config. Left click opens
// Google Calendar as a web app; right click toggles to a date format.
BarWidget {
  id: root

  property bool showDate: false

  readonly property date now: clock.date

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  label: "  " + (showDate
    ? Qt.formatDateTime(now, "ddd dd MMM yyyy")
    : Qt.formatDateTime(now, "ddd dd h:mm AP"))
  accent: Color.maroon

  onClicked: run(["brave", "--app=https://calendar.google.com"])
  onRightClicked: showDate = !showDate
}
