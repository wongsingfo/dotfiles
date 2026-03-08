---
name: google-scholar-bibtex
description: Load this skill when the task is to find the most relevant Google Scholar paper by keyword and return its abstract and BibTeX entry.
---

# Google Scholar Abstract + BibTeX Skill

## Use Cases

- The user provides one or more keywords and asks for the most relevant paper on Google Scholar.
- The output must include both the paper abstract and a BibTeX entry.
- The result should explicitly state uncertainty and source provenance.

## Input

- `query`: the original search keywords (must be preserved as-is).
- Optional `n`: number of top results to return, default is `1`.

## Tool Constraints

- Use MCP browser tools for the full workflow (`chrome-devtools_*`).
- Prefer snapshot-based semantic element targeting (`chrome-devtools_take_snapshot`) over fragile CSS selectors.
- Retry each step at most 2 times; then report the failure point.

## Execution Flow

1. Open `https://scholar.google.com/`.
2. Prefer direct query URL:
   `https://scholar.google.com/scholar?q=<URL-encoded query>&hl=en`.
   - If direct URL access fails, fall back to typing into the homepage search box.
3. Identify the first natural search result as the primary candidate.
   - If the first result is not a paper (e.g., author profile/list page), skip to the next paper result.
4. Extract basic metadata from the selected result card: title, author/venue line, year, source URL.
5. Get BibTeX:
   - Click `Cite`/`引用`.
   - In the citation modal, click `BibTeX`.
   - Read the full BibTeX text.
6. Get abstract:
   - Prefer opening the landing page and extracting the `Abstract`/`摘要` section text.
   - If the landing page is inaccessible or unstable to parse, fall back to Scholar snippet and mark it as `snippet`.
7. Return structured output, and mark abstract source as `publisher` or `scholar_snippet`.

## Quick Execution Template (Recommended)

Use this fixed sequence for speed:

1. `chrome-devtools_new_page` to open:
   `https://scholar.google.com/scholar?q=<URL-encoded query>&hl=en`
2. `chrome-devtools_take_snapshot`, then read the result cards on the first page and find the relevant ones.
3. Click `Cite`/`引用`, then `chrome-devtools_wait_for` `BibTeX`.
4. Click `BibTeX`, then read text from `scholar.googleusercontent.com/scholar.bib`.
5. Open the title URL in a new page and extract `ABSTRACT`/`Abstract`/`摘要` text.
6. Assemble and return JSON.

## Element Targeting Priority

Use visible text semantics first:

1. Search box: `Search` or `搜索`
2. Citation button: `Cite` or `引用`
3. Citation modal anchor: `BibTeX` (often with `MLA`/`APA` nearby)
4. Abstract headings: `ABSTRACT`, `Abstract`, `摘要`

If duplicate entries appear, choose the highest-ranked natural result with a complete `Cite`/`引用` action block.

## Generic Extraction Rules

- Year: match 4-digit year from author/venue line; use `null` if not found.
- Title: use the main result title, not `[PDF]` link text.
- URL: prefer title URL; if missing, fall back to source link URL.
- Abstract:
  - Prefer publisher landing-page abstract.
  - If only snippet is reliably available, use snippet and mark `scholar_snippet`.
- BibTeX: preserve original line breaks and braces; do not reorder fields.

## Exception Detection Checklist

After each navigation or click, check whether the page contains:

- `CAPTCHA`, `reCAPTCHA`, `I am not a robot`
- `unusual traffic`, `verify you are human`, or equivalent wording
- verification UI without normal Scholar result list

If any condition is hit, switch immediately to Human Verification Handling and stop automation.

## Practical Speed Notes

- English and Chinese Scholar UIs differ mainly in labels; workflow is the same (`Search/搜索`, `Cite/引用`).
- `chrome-devtools_wait_for` on `BibTeX` is usually faster than repeated snapshot polling.
- BibTeX pages are often plain text; reading root text is sufficient.
- For abstracts, target the paragraph immediately below an abstract heading to avoid nav/footer text.

## Human Verification Handling

- If CAPTCHA/reCAPTCHA/robot verification or anti-bot blocking appears, stop immediately.
- Send one request to user: please complete human verification manually and reply `done`.
- Do not continue clicking, refreshing, or submitting new requests until user confirms.

## Output Format

Return this JSON shape (do not omit keys; use `null` for missing values):

```json
{
  "query": "<original query>",
  "source": "Google Scholar",
  "results": [
    {
      "rank": 1,
      "title": "<paper title>",
      "authors_and_venue": "<raw authors and venue line>",
      "year": 2020,
      "url": "<landing page URL>",
      "abstract": "<abstract text or Scholar snippet>",
      "abstract_source": "publisher",
      "bibtex": "@article{...}"
    }
  ],
  "notes": [
    "If human verification is triggered, user takeover is required before continuing."
  ]
}
```

## Quality Checklist

- Title matches BibTeX `title` field (allowing minor case differences).
- BibTeX includes entry type and citation key (e.g., `@article{key, ...}`).
- Abstract is non-empty; if snippet-based, `abstract_source = scholar_snippet`.
- URL is reachable, or failure reason is explicitly stated (access control, region block, anti-bot wall).

