# Extracting Text Without a Full Render

Status: technique note (2026-07-27, single occurrence so far — not yet a
skill; see `process-vs-work-doctrine` rule 1). Promote to a skill if this
recurs.

When the Read tool can't usefully return a file's text directly:

- **`.docx`**: unzip it and strip XML tags from `word/document.xml`. A `.docx`
  is a zip archive; the document body is plain XML with the visible text
  wrapped in `<w:t>` runs. `unzip -p file.docx word/document.xml` piped
  through an XML-tag strip (e.g. `sed -e 's/<[^>]*>//g'`) gets readable text
  without a full document-conversion tool.
- **Large mermaid-exported `.svg`**: grep for the `>text<` patterns. A large
  rendered diagram's SVG can be too big to read in full, but the visible
  labels are still plain text between tag boundaries — `grep -oE '>[^<]+<'
  file.svg` pulls out the label strings without parsing the SVG structurally.
