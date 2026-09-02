Status: technique note (2026-09-01, single session, ~33 uses — not yet a
skill or WebFetch-tool change; see `process-vs-work-doctrine` rule 1).
Promote if this recurs across a second dated session.

`WebFetch` on `x.com`/`twitter.com` URLs fails with `HTTP 402 Payment
Required` — X blocks unauthenticated automated fetching outright, including
plain tweet text (not just embeds/media).

Workaround: fetch through the `fxtwitter.com` read-only mirror instead:

```
https://api.fxtwitter.com/<handle>/status/<id>
```

(swap `x.com`/`twitter.com` for `api.fxtwitter.com`, keep the same path).
Returns tweet text, author, and linked URLs reliably via `WebFetch`. Verified
against 33 tweet URLs pulled from a manually-copied X bookmarks batch in this
session — 100% success rate, vs. 0% (402) fetching `x.com` directly.

Caveats observed:
- Doesn't resolve X's own long-form "Articles" (`x.com/i/article/...`) —
  only the tweet that links to one; the article body itself stays unfetched.
- Content quality depends on the small model WebFetch summarizes through;
  cross-check anything load-bearing rather than trusting the summary verbatim.
