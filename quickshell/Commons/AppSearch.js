// App search scoring, adapted from omarchy quatro's shell/services/AppSearch.js
// (trimmmed to what the launcher needs). All functions are pure so this can
// be imported by the launcher and unit-tested standalone.

function entryName(entry) {
  return String((entry && entry.name) || (entry && entry.id) || "")
}

function keywordText(entry) {
  try {
    if (entry && entry.keywords && typeof entry.keywords.join === "function")
      return entry.keywords.join(" ")
  } catch (e) {}
  return ""
}

function entrySearchText(entry) {
  if (!entry) return ""
  return [entry.name, entry.genericName, entry.comment, keywordText(entry), entry.id]
    .join(" ")
    .toLowerCase()
}

function words(value) {
  return String(value || "")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[._:/\\-]+/g, " ")
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter(w => w.length > 0)
}

function entryAcronym(entry) {
  return words([entry && entry.name, entry && entry.genericName, keywordText(entry), entry && entry.id].join(" "))
    .map(w => w.charAt(0))
    .join("")
}

function termMatches(entry, term) {
  if (!term) return true

  const name = entryName(entry).toLowerCase()
  const id = String((entry && entry.id) || "").toLowerCase()
  const haystack = entrySearchText(entry)

  if (name.indexOf(term) >= 0) return true
  if (id.indexOf(term) >= 0) return true
  if (haystack.indexOf(term) >= 0) return true

  // short queries match acronyms: "ff" → Firefox
  return term.length <= 5 && entryAcronym(entry).indexOf(term) >= 0
}

function allTermsMatch(entry, query) {
  const terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (let i = 0; i < terms.length; i++)
    if (terms[i] && !termMatches(entry, terms[i])) return false
  return true
}

// Higher is better; -1 means no match.
function fuzzyScore(entry, query) {
  const q = String(query || "").trim().toLowerCase()
  if (!q) return 0
  if (!allTermsMatch(entry, q)) return -1

  const name = entryName(entry).toLowerCase()
  const id = String((entry && entry.id) || "").toLowerCase()

  if (name === q) return 1000
  if (name.indexOf(q) === 0) return 800 - name.length
  if (id.indexOf(q) === 0) return 700 - id.length

  const nameAt = name.indexOf(q)
  if (nameAt >= 0) return 600 - nameAt - name.length * 0.1

  if (entryAcronym(entry).indexOf(q) >= 0) return 500

  const hayAt = entrySearchText(entry).indexOf(q)
  if (hayAt >= 0) return 300 - hayAt * 0.1

  // multi-term: every term matched somewhere
  return 100
}

function visibleEntries(entries) {
  const out = []
  for (let i = 0; i < entries.length; i++) {
    const e = entries[i]
    if (e && !e.noDisplay && entryName(e).length > 0)
      out.push(e)
  }
  return out
}

// Returns entries sorted best-first for query ("" → alphabetical).
function search(entries, query) {
  const q = String(query || "").toLowerCase().trim()
  const visible = visibleEntries(entries)

  if (!q) {
    return visible.slice().sort((a, b) =>
      entryName(a).toLowerCase() < entryName(b).toLowerCase() ? -1 : 1)
  }

  const scored = []
  for (const e of visible) {
    const s = fuzzyScore(e, q)
    if (s >= 0)
      scored.push({ entry: e, score: s })
  }
  scored.sort((a, b) => b.score - a.score
    || (entryName(a.entry).toLowerCase() < entryName(b.entry).toLowerCase() ? -1 : 1))
  return scored.map(x => x.entry)
}

if (typeof module !== "undefined") {
  module.exports = {
    entryName: entryName,
    entrySearchText: entrySearchText,
    fuzzyScore: fuzzyScore,
    search: search,
    visibleEntries: visibleEntries,
  }
}
