// Pure, side-effect-free helpers behind notification persistence.
//
// This file is loaded by QML (Notifications.qml) and by Node (the test at
// test/notification-logic.test.js), so it must not touch QML globals or the
// filesystem. It only shapes data: snapshot a live Notification, decide where
// its file-backed images should be copied, and serialize/parse/trim the
// on-disk history. All I/O lives in Notifications.qml.

// History cap. The on-disk directory is trimmed to the same number the model
// keeps, so a restart cannot resurrect entries the model has already dropped.
var MAX_HISTORY = 50

// Upper bound on a copied image. Anything larger is skipped rather than
// allowed to fill the state directory or stall the copy.
var MAX_IMAGE_BYTES = 5 * 1024 * 1024

// Copy the fields we need out of a live Notification. Quickshell destroys the
// object shortly after `closed`, so anything not copied here is lost.
function snapshotOf(notification, timestamp) {
  return {
    id: notification.id,
    appName: notification.appName || "",
    appIcon: notification.appIcon || "",
    summary: notification.summary || "",
    body: notification.body || "",
    image: notification.image || "",
    urgency: notification.urgency,
    timestamp: timestamp
  }
}

// `<timestamp>-<id>` identifies an entry; the same stem names its JSON file
// and its copied images, so dropping an entry drops everything it owns.
function entryStem(entry) {
  return String(entry.timestamp) + "-" + String(entry.id)
}

function entryFileName(entry) {
  return entryStem(entry) + ".json"
}

// A sender-provided icon is either a theme name (resolved by the icon
// provider) or a file URL / absolute path. Only the latter can be copied.
function isFileBacked(source) {
  return typeof source === "string" && source.length > 0 &&
    (source.indexOf("file:") === 0 || source.charAt(0) === "/")
}

// Chromium passes web-notification favicons as `file:///path` URLs; the copy
// command needs the plain path.
function fileUrlToPath(source) {
  if (typeof source !== "string")
    return source
  if (source.indexOf("file://") === 0) {
    var path = source.substring(7)
    try {
      return decodeURIComponent(path)
    } catch (e) {
      return path
    }
  }
  return source
}

function pathToFileUrl(path) {
  return "file://" + path.split("/").map(function (part) {
    return encodeURIComponent(part)
  }).join("/")
}

// The filesystem size of a copied image must be a known, non-negative number
// no larger than MAX_IMAGE_BYTES. `bytes < 0` stands for "not a regular file".
function withinSizeCap(bytes) {
  return typeof bytes === "number" && bytes >= 0 && bytes <= MAX_IMAGE_BYTES
}

// Rewrite every file-backed image on `entry` to point at its copy under
// `imageDir`, and return the copy commands the shell should run. Themed icons
// are left untouched. The copy command enforces the regular-file and size
// guards; this function only decides what is worth copying.
function persistableEntry(entry, imageDir) {
  var result = {
    id: entry.id,
    appName: entry.appName,
    appIcon: entry.appIcon,
    summary: entry.summary,
    body: entry.body,
    image: entry.image,
    urgency: entry.urgency,
    timestamp: entry.timestamp
  }
  var stem = entryStem(entry)
  var copies = []
  var roles = [ "appIcon", "image" ]

  for (var i = 0; i < roles.length; i++) {
    var role = roles[i]
    if (!isFileBacked(result[role]))
      continue
    var path = imageDir + "/" + stem + "-" + role
    copies.push({
      role: role,
      source: fileUrlToPath(result[role]),
      path: path
    })
    result[role] = pathToFileUrl(path)
  }

  return { entry: result, copies: copies, stem: stem }
}

function serializeEntry(entry) {
  return JSON.stringify(entry)
}

// Each entry is written as one compact line; parse every non-empty line and
// skip anything corrupt rather than failing the whole load.
function parseEntries(text) {
  var entries = []
  if (!text)
    return entries
  var lines = text.split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (line === "")
      continue
    try {
      var entry = JSON.parse(line)
      if (entry && typeof entry.timestamp === "number")
        entries.push(entry)
    } catch (e) {
      // Skip a truncated or hand-edited line.
    }
  }
  return entries
}

// Newest first, capped at `max`, with the overflow returned separately so the
// caller can delete what the model is about to drop.
function trimPlan(entries, max) {
  var sorted = entries.slice().sort(function (a, b) {
    return b.timestamp - a.timestamp
  })
  if (max >= 0 && sorted.length > max)
    return { kept: sorted.slice(0, max), evicted: sorted.slice(max) }
  return { kept: sorted, evicted: [] }
}

function historyRows(entries, max) {
  return trimPlan(entries, max).kept
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    MAX_HISTORY: MAX_HISTORY,
    MAX_IMAGE_BYTES: MAX_IMAGE_BYTES,
    snapshotOf: snapshotOf,
    entryStem: entryStem,
    entryFileName: entryFileName,
    isFileBacked: isFileBacked,
    fileUrlToPath: fileUrlToPath,
    pathToFileUrl: pathToFileUrl,
    withinSizeCap: withinSizeCap,
    persistableEntry: persistableEntry,
    serializeEntry: serializeEntry,
    parseEntries: parseEntries,
    trimPlan: trimPlan,
    historyRows: historyRows
  }
}
