#!/usr/bin/env node
// Tests for quickshell/Commons/NotificationLogic.js, the pure half of
// notification persistence. Run with `node test/notification-logic.test.js`.

const test = require("node:test")
const assert = require("node:assert/strict")
const path = require("node:path")

const Logic = require(
  path.join(__dirname, "..", "quickshell", "Commons", "NotificationLogic.js")
)

test("snapshotOf copies live fields and defaults the optional ones", () => {
  const notification = {
    id: 7,
    appName: "Firefox",
    appIcon: "firefox",
    summary: "Build finished",
    body: "all green",
    image: "/tmp/shot.png",
    urgency: "critical"
  }
  const entry = Logic.snapshotOf(notification, 1700000000000)
  assert.deepEqual(entry, {
    id: 7,
    appName: "Firefox",
    appIcon: "firefox",
    summary: "Build finished",
    body: "all green",
    image: "/tmp/shot.png",
    urgency: "critical",
    timestamp: 1700000000000
  })
})

test("snapshotOf fills missing fields instead of leaking undefined", () => {
  const entry = Logic.snapshotOf({ id: 1, urgency: "normal" }, 5)
  assert.equal(entry.appName, "")
  assert.equal(entry.appIcon, "")
  assert.equal(entry.summary, "")
  assert.equal(entry.body, "")
  assert.equal(entry.image, "")
  assert.equal(entry.timestamp, 5)
})

test("entryStem and entryFileName identify an entry", () => {
  const entry = { id: 42, timestamp: 1700000000123 }
  assert.equal(Logic.entryStem(entry), "1700000000123-42")
  assert.equal(Logic.entryFileName(entry), "1700000000123-42.json")
})

test("isFileBacked only accepts file URLs and absolute paths", () => {
  assert.equal(Logic.isFileBacked("firefox"), false)
  assert.equal(Logic.isFileBacked(""), false)
  assert.equal(Logic.isFileBacked(undefined), false)
  assert.equal(Logic.isFileBacked("file:///tmp/favicon.png"), true)
  assert.equal(Logic.isFileBacked("/tmp/favicon.png"), true)
})

test("fileUrlToPath strips the scheme and decodes escapes", () => {
  assert.equal(Logic.fileUrlToPath("file:///tmp/a%20b/c.png"), "/tmp/a b/c.png")
  assert.equal(Logic.fileUrlToPath("/tmp/plain.png"), "/tmp/plain.png")
})

test("pathToFileUrl round-trips through fileUrlToPath", () => {
  const original = "/tmp/a b/weird name.png"
  assert.equal(Logic.fileUrlToPath(Logic.pathToFileUrl(original)), original)
})

test("withinSizeCap rejects non-numbers, negatives and oversized files", () => {
  assert.equal(Logic.withinSizeCap(0), true)
  assert.equal(Logic.withinSizeCap(1024), true)
  assert.equal(Logic.withinSizeCap(Logic.MAX_IMAGE_BYTES), true)
  assert.equal(Logic.withinSizeCap(Logic.MAX_IMAGE_BYTES + 1), false)
  assert.equal(Logic.withinSizeCap(-1), false)
  assert.equal(Logic.withinSizeCap("12"), false)
})

test("persistableEntry leaves themed icons alone", () => {
  const entry = {
    id: 1,
    appName: "Firefox",
    appIcon: "firefox",
    summary: "s",
    body: "b",
    image: "",
    urgency: "normal",
    timestamp: 100
  }
  const prepared = Logic.persistableEntry(entry, "/state/images")
  assert.equal(prepared.stem, "100-1")
  assert.equal(prepared.entry.appIcon, "firefox")
  assert.deepEqual(prepared.copies, [])
})

test("persistableEntry copies file-backed icons and rewrites the entry", () => {
  const entry = {
    id: 9,
    appName: "Chromium",
    appIcon: "file:///tmp/fav%20icon.png",
    summary: "s",
    body: "b",
    image: "/tmp/attached.png",
    urgency: "low",
    timestamp: 200
  }
  const prepared = Logic.persistableEntry(entry, "/state/images")
  assert.equal(prepared.entry.appIcon, "file:///state/images/200-9-appIcon")
  assert.equal(prepared.entry.image, "file:///state/images/200-9-image")
  assert.deepEqual(prepared.copies, [
    {
      role: "appIcon",
      source: "/tmp/fav icon.png",
      path: "/state/images/200-9-appIcon"
    },
    {
      role: "image",
      source: "/tmp/attached.png",
      path: "/state/images/200-9-image"
    }
  ])
})

test("serializeEntry writes one compact line that round-trips", () => {
  const entry = {
    id: 3,
    appName: "App",
    appIcon: "",
    summary: "multi\nline",
    body: "b",
    image: "",
    urgency: "normal",
    timestamp: 300
  }
  const text = Logic.serializeEntry(entry)
  assert.equal(text.indexOf("\n"), -1)
  assert.deepEqual(JSON.parse(text), entry)
})

test("parseEntries skips blanks, corruption and non-numeric timestamps", () => {
  const good = {
    id: 1,
    appName: "A",
    appIcon: "",
    summary: "s",
    body: "b",
    image: "",
    urgency: "normal",
    timestamp: 10
  }
  const text = [
    "",
    JSON.stringify(good),
    "{not json",
    JSON.stringify({ id: 2, timestamp: "nope" }),
    "   ",
    JSON.stringify(Object.assign({}, good, { id: 3, timestamp: 11 }))
  ].join("\n")
  const entries = Logic.parseEntries(text)
  assert.deepEqual(entries.map(e => e.id), [1, 3])
})

test("parseEntries tolerates empty and undefined input", () => {
  assert.deepEqual(Logic.parseEntries(""), [])
  assert.deepEqual(Logic.parseEntries(undefined), [])
})

test("trimPlan sorts newest-first, keeps the cap and returns the overflow", () => {
  const entries = [
    { id: 1, timestamp: 10 },
    { id: 2, timestamp: 30 },
    { id: 3, timestamp: 20 }
  ]
  const plan = Logic.trimPlan(entries, 2)
  assert.deepEqual(plan.kept.map(e => e.id), [2, 3])
  assert.deepEqual(plan.evicted.map(e => e.id), [1])
})

test("trimPlan keeps everything when under the cap", () => {
  const entries = [{ id: 1, timestamp: 1 }]
  const plan = Logic.trimPlan(entries, 50)
  assert.deepEqual(plan.kept.map(e => e.id), [1])
  assert.deepEqual(plan.evicted, [])
})

test("historyRows is the kept half of trimPlan", () => {
  const entries = [{ id: 1, timestamp: 1 }, { id: 2, timestamp: 2 }]
  assert.deepEqual(Logic.historyRows(entries, 1).map(e => e.id), [2])
})
