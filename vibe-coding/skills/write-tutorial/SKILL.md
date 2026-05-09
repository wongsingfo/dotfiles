---
name: write-tutorial
description: Guidelines for writing and reviewing wiki tutorial pages. Invoke when creating new pages, rewriting sections, or reviewing existing content for quality.
---

# Writing Tutorials for this Wiki

You are writing technical tutorials for systems engineers preparing for interviews on LLM infrastructure. Apply these principles whenever you create or revise wiki pages.

## Core Principle: Explain the Why, Not the What

You are not a code interpreter. The reader can read the code. Your job is to surface what the code does not say:

- **Design rationale**: Why was this approach chosen over alternatives? What constraints drove the design?
- **Design principles**: What recurring patterns or invariants does the code maintain? What would break if they were violated?
- **Non-obvious implications**: What are the consequences of a design choice that aren't apparent from reading the code alone?
- **Design evolution**: When a design supersedes an older approach, explain *why the old way broke* before presenting the new one. Show the causal chain (e.g., "single-core world → multi-core world → COW's atomic refcount became the bottleneck → SSO replaced it").

Bad (restating code):

> `num_channels = num_sms / 2` divides the number of SMs by 2 to get the number of channels.

Good (explaining the design):
> `num_channels = num_sms / 2` — each channel is a pair of blocks: one sender (even block ID), one receiver (odd block ID). The sender pushes data into the remote GPU's buffer via NVLink; the receiver polls the local buffer for incoming data. This pairing enables pipelined transfer and consumption within a single kernel launch.

## Self-Containment

Every page must be readable without requiring the reader to have studied the codebase first.

- **Define before use**: When introducing a term, variable name, or concept, explain it at the point of first use. Restructure the page so the dependency flows top-down. Forward-reference ("as explained in Section 5") or a side note ("explain it immediately after, in a quote block")
- **Provide dimensional context**: When presenting a data structure or buffer layout, state what each field represents, what its dimensions are, and why those dimensions are what they are. A bare `num_ranks × num_ranks × sizeof(int)` is incomplete without explaining what each axis means.

### Dependency Audit Before Writing

Before writing a tutorial about system X, list every concept X depends on that a new reader might not know. For each dependency, decide: inline explanation or pointer to another page. Do this audit before drafting, not during review.

This is critical for systems papers: the paper assumes the reader knows the prior system it builds on (e.g., PagedAttention, FlashAttention). Your wiki reader may not. A "前置" section that briefly explains the dependency's core mechanism (page table, gather/scatter, online softmax) costs 5-10 lines and makes the rest of the page comprehensible to someone who hasn't read the cited paper.

Test your audit: after writing, find the earliest sentence that uses a term the reader hasn't seen defined. If it's not in the first section, you missed a dependency.

### Roadmap Paragraph

After describing the problem a system solves, provide a short paragraph that names each major technique and explicitly ties it to the sub-problem it addresses. Example: "RPA proposes three techniques: A solves X, B solves Y, C solves Z." This gives the reader a mental index before the detailed sections begin. Without it, the reader enters the first technique section not knowing whether there are two more or ten more, or how they relate to each other.

## Adding Content to Existing Pages

When adding new content to an existing page, default to **weaving it into the existing structure** rather than creating a standalone section:

- **Extend symbol tables** with new notation instead of creating a second table.
- **Extend existing subsections** where the new topic naturally belongs (e.g., a new gating mechanism belongs in the Gate section, not a new top-level section).
- **Extend existing formulas/bounds** with the new constraint inline (e.g., "Group-limited gating reduces this bound to $G'$" within the Dispatch section).
- **Place implementation details in the API section** as a preprocessing step, not as a separate "Implementation" section.
- **Add cross-cutting concerns as inline remarks** (quote blocks, parentheticals) within the sections they affect, not as standalone paragraphs.

Only create a new section when the content has no natural home in the existing structure. A new section should earn its place by covering a topic that is (a) orthogonal to all existing sections and (b) substantial enough to stand alone.

## Tone and Style

- **Be technical and formal.** Do not use metaphors, analogies, or informal language. Say "the sender writes data to the remote buffer" not "the sender throws data over the fence."
- **Be precise about actor and location.** Distributed systems writing is error-prone when it's unclear which GPU, which process, or which memory space is involved. Always state explicitly: "SM on GPU A writes to GPU B's buffer via NVLink pointer" rather than "data is sent."
- **Use active voice when the actor matters.** Name who does what. "The dispatch kernel writes to the remote NVLink buffer" beats "the remote NVLink buffer is written to." Reserve passive for cases where the agent is genuinely unknown or irrelevant ("the page was evicted" when eviction policy is the topic, not the evictor).
- **Prefer concrete over abstract.** Numbers, byte sizes, data types, and struct definitions are more useful than vague descriptions. "An 8-byte struct containing `src_rdma_rank` (int) and `is_token_in_nvl_rank_bits` (int, 8-bit packed bitmap)" is better than "a small metadata structure." Replace category words ("factors", "aspects", "considerations", "issues", "elements") with the specific items they refer to.
- **Ground every performance claim with a number.** Never write "NVLink is fast" or "this reduces latency significantly." Write "H100 NVLink 4.0: 900 GB/s bidirectional" or "prefill latency drops from 12ms to 3.1ms." If you don't have the number, say so explicitly rather than using vague qualifiers.
- **Cut filler phrases.** "In order to" → "to". "Due to the fact that" → "because". "At this point in time" → "now". Delete "it is important to note that" entirely. "May potentially" and "could possibly" are redundant hedges — pick one.
- **Use everyday English over corporate jargon.** "Use" over "leverage" / "utilize". "Method" over "methodology". "Feature" over "functionality". "Start" or "build" over "operationalize". Reserve specialized vocabulary for terms that carry distinct technical meaning (`backpropagation`, `quantization`, `paged attention`).
- **Use affirmative form.** "Trivial" not "not important"; "rarely" not "not often"; "fails" not "does not succeed"; "small" not "not large". One affirmative word beats two negating words. Honest negation ("no proxy GPU") remains correct when the proposition is genuinely negative.
- **Avoid clichés and dying metaphors.** Do not write "pushes the boundaries", "paves the way", "state-of-the-art", "paradigm shift", "groundbreaking", "unlocks full potential". If you cannot replace the cliché with a specific number, mechanism, or comparison, the cliché was hiding the absence of substance.
- **Calibrate verbs to evidence.** Experimental results "show" or "suggest"; theoretical derivations "imply" or "prove"; benchmarks "measure". Do not write "revolutionizes" or "dramatically improves" — state the delta (e.g., "reduces p99 from 310ms to 180ms"). Avoid "best" unless you have compared against the strongest alternative; avoid "only" unless you have ruled out alternatives.
- **Distinguish rewrites from additions.** When rewriting an existing page, identify what the original got right and preserve it. Cut length by removing redundancy and code dumps, not by removing substance.

## Sentence and Paragraph Discipline

Most writing problems live at the sentence level. Apply these rules during drafting and review.

- **Vary sentence length; split sentences over 30 words.** A paragraph of five 25-word sentences reads as monotone. Mix short (8 words), medium (15-20), and long (25-30). Short sentences land points; long sentences carry qualification and detail. When a long sentence is unavoidable, make the surrounding ones short to balance.
- **Place new or important information at the sentence end.** The sentence end is the stress position — readers remember what they read last. "On SQuAD 2.0, the new architecture improves F1 by 3.2 points" lands the result; "A 3.2-point improvement in F1 was demonstrated by the new architecture on SQuAD 2.0" buries it. The same logic applies at the paragraph level: opening sentence frames; final sentence lands the main point; middle sentences support.
- **Keep subject close to verb.** When a long parenthetical or relative clause separates them by 8+ words, split into two sentences or move the clause to the end. Readers hold the subject in working memory until the verb arrives; long gaps cause re-reading.
- **Use parallel structure in lists.** If item 1 is a verb-initial clause, items 2 and 3 must also be verb-initial. "The pipeline cleans the data, extracts features, and trains the model" — not "cleans the data, feature extraction, and then trains the model." Decide the form (verb phrase? noun phrase? subject-verb-object?) before writing the list, then hold it.
- **Do not start consecutive sentences with the same word.** `The method... The method... The method...` is a template-fill pattern that signals AI-generated drafting. Vary the opener (topic-fronted vs subject-fronted vs connective) or combine the sentences. Pronoun openers (`It`, `We`, `They`) are the most common offenders.
- **Avoid sentence-initial "Additionally" / "Furthermore" / "Moreover" / "In addition".** Connect ideas by content, not transition words. The next sentence is obviously an addition because of what it says. Reserve explicit transitions for rare cases where the logical move (contrast, concession, non-obvious causality) needs to be flagged.
- **Use consistent terms throughout.** Once you define an abbreviation (`KV cache`), use it — don't drift to `key-value cache` / `attention cache` / `KV-store`. Once you name an entity (`PagedAttention`), don't paraphrase it (`paging-based attention`, `the paging mechanism`). Variety in vocabulary masks identity in technical writing.
- **Do not bullet-ify connected prose.** Use bullets for genuinely parallel enumerations (struct fields, config options, API surfaces, checklist steps). Use paragraphs for argument, cause-and-effect, and walkthrough narrative. The test: if reading only the first few words of each bullet does not recover meaning, the bullets are sentence shards — convert to prose. Resist forced 3-item triads ("three key strengths") when the content is two items or a sentence.
- **Do not close every paragraph with a summary sentence.** "Overall, this means..." / "In summary..." / "Thus, the contribution is..." restates what the paragraph already established. Trust the content to land its own point. Summary closers are correct only for the final paragraph of a section or for long-form skim targets.
- **Avoid em dashes (—) and en dashes (–) as casual punctuation.** They are a distinctive AI-tell. Prefer commas for appositives, semicolons for linked independent clauses, colons for expansions, and parentheses for asides. En dashes remain correct for numeric ranges (`1-3`, `2020-2026`) and paired names (`Stein-Strömberg theorem`); hyphens in compound words (`zero-shot`, `command-line`) are not dashes.

## Mathematical Content

When a topic involves formal notation (loss functions, communication complexity, scheduling theory):

- **Pair every formula with an intuitive translation.** The formula is the specification; the translation is the intuition. Present both. Example: show $A_t = (R_t + \gamma V(s_{t+1})) - V(s_t)$ then write "Advantage = what actually happened minus what we expected."
- **Translate to hardware/code terms.** After the mathematical statement, explain what it means for the implementation: which tensor has which shape, which operation maps to which kernel, where the memory bottleneck is.
- **Do not skip notation definitions.** Every variable in a formula must be defined at or before first use. Readers should never have to guess what a subscript means.

## Mathematical and Architectural Reasoning

When writing about theoretical foundations, proofs, or multi-level architectures (not just code):

- **Illustrate parameters before formulas.** Before presenting a formula with abstract parameters ($r$, $n$, $m$), provide a small concrete example with a diagram that makes the parameters tangible. The reader should be able to point at the diagram and say "that's $r$, that's $n$." Then present the formula. This is distinct from "follow a formula with a concrete calculation" (which applies *after* the formula); this applies *before*.
- **Preempt common misconceptions.** For proofs and derivations, identify the most likely wrong inference and address it in a quote block. Ask yourself: "what would a reader who half-understands this topic guess?" If the obvious guess is wrong (e.g., $m \geq r \times n$ instead of $m \geq 2n - 1$), explain exactly why by identifying the hidden structural property that invalidates the naive reasoning.
- **Ground abstract parameters in physical reality.** When analysis uses a parameter like $N = 4096$, state explicitly whether such values exist physically and what the real-world range is. Abstract math and engineering reality must be bridged, not left for the reader to reconcile.
- **Distinguish theoretical models from engineering practice.** When presenting a standard model (e.g., $k/2$ symmetric port split in fat-tree), note explicitly whether this is the common deployment practice or a theoretical simplification. State the real-world alternatives and when they apply. If unsure, verify via web search before writing.
- **Explain domain jargon motivation.** When introducing domain terms (uplink/downlink, spine/leaf, ToR), explain not just the definition but *why* the term is named that way. The naming convention often encodes the mental model (e.g., "uplink" comes from the tree-shaped topology diagram where the core is drawn at the top).
- **State sharing explicitly in multi-level structures.** In hierarchical architectures, explicitly state which components are shared across levels vs replicated per level. After deriving component counts, verify by computing edge counts from both sides of each layer boundary — they must match. Example: "total Agg uplinks = $k \times (k/2)^2 = k^3/4$; total Core downlinks = $(k/2)^2 \times k = k^3/4$ — they match."

## Quantitative Analysis

When deriving communication volumes, memory footprints, or performance bounds:

- **Start with the simplest correct formula**, then add refinements (e.g., basic dispatch volume → group-limited gating correction → FP8 vs BF16 distinction).
- **Always follow a formula with a concrete calculation.** Use the system's actual configuration (e.g., DeepSeek-V3: B=4096, H=7168, K=8) to produce a number the reader can verify.
- **Present parameter sweeps as tables**, not just formulas. A table showing communication volume at EP=16/32/64/128 is immediately scannable; a formula requires mental arithmetic.
- **Distinguish per-rank from aggregate quantities.** State explicitly: "per rank" or "total across all ranks."
- **Note formula limitations explicitly.** If a formula assumes uniform routing, say so. If group-limited gating changes the bound, state the correction or note that the precise value is routing-dependent.
- **Verify arithmetic in concrete examples.** After writing a formula and its example calculation, re-compute the number independently. If the formula gives $V = B \cdot K \cdot H \cdot (N-1)/N \cdot s$ and you claim $\approx 114$ MB, plug in the numbers and verify: $4096 \times 8 \times 7168 \times 31/32 \times 1 = 228$ MB, not 114. Arithmetic errors in examples undermine trust in the entire analysis.
- **Justify every factor from first principles.** For each factor in a formula, state what it counts. "$K$ expert selections per token, $(G-1)/G$ on remote nodes, $H \cdot s$ bytes per token" — each factor maps to a concrete quantity. If you cannot state what a factor counts, the formula may be wrong.
- **Keep units and scope consistent across sections.** When presenting numbers in different sections or tables, ensure units and scope labels match. If one table shows server counts and another shows switch counts, label them clearly and add a comparison when both are available for the same configuration. A reader who sees "2,048" in one section and "5,120" in another will compare them — make sure the units are obvious.

## Execution Walkthroughs

For code paths, protocols, and multi-step algorithms, trace through a concrete execution with specific states:

- **Show the sequence, not just the description.** Instead of "the event loop processes callbacks," walk through one iteration: what `_run_once` does, what the ready queue looks like, which callback fires next.
- **Tie each step to an API call or code construct.** "Step 2: RDMA Write via `ibv_post_send`" is better than "Step 2: data is transferred over the network."
- **State variable values at each step when relevant.** "After step 3, `buffer_offset = 4096`, `remaining_bytes = 0`, completion flag is set" makes the trace concrete and debuggable.

## Writing from Source Code

When the task is to analyze source code and write about it:

- **Lead with the design decision, not the code path.** The reader wants to know *why* the code is structured this way, not a line-by-line walkthrough. Present the design first, then use code to illustrate.
- **Quote code sparingly.** Include a code snippet only when it reveals a non-obvious mechanism (e.g., the `-value - 1` encoding trick to distinguish zero from uninitialized). Do not paste struct definitions or function signatures unless each field/parameter is explained.
- **Trace one concrete data path end-to-end.** For multi-file systems, pick one representative flow (e.g., "a token travels from source GPU to destination GPU") and trace it through all layers, naming files and line ranges. This is more useful than describing each file in isolation.
- **Name the actors explicitly.** "The sender warp on GPU A writes to GPU B's NVLink buffer" — never "data is sent."
- **Cite source locations as `file.cu:line_range`** for key mechanisms, so readers can verify. But don't cite every line — only the ones that would be hard to find.

### Verification Before Writing

A single wrong architectural assumption can cascade across an entire page (formulas, diagrams, walkthroughs, callout blocks). Before writing, verify these high-risk claims against the source code:

- **Who initiates the operation?** If you write "GPU A sends data via X to GPU B," confirm in the code which GPU's kernel executes the send. In distributed systems, the difference between "each GPU sends independently" and "one GPU proxies for the group" changes every formula and diagram on the page.
- **Which memory is local vs remote?** When a GPU writes to a pointer, check whether that pointer is a local HBM address or a remote address accessed via NVLink/RDMA. Writing to `buffer_ptrs[self]` is a local HBM operation; writing to `buffer_ptrs[peer]` is a NVLink write. Mislabeling this produces incorrect traffic analysis.
- **When does a synchronization happen?** If you describe CPU-GPU sync, verify which kernel writes the signal and which kernel depends on it. "After dispatch" vs "between notify and dispatch" changes the entire sync protocol description.
- **Verify every factor in a formula.** Each multiplicative factor must correspond to a concrete counting argument. If a formula includes $1/N_{\text{local}}$, you must be able to say precisely what is being divided by 8 and why. "Proxy shares work" is not a valid justification if there is no proxy.

After writing a claim about architecture, data flow, or formulas, **grep for contradictions** within the same page. If you described "no proxy" in one paragraph but wrote "proxy GPU" in another, one of them is wrong.

## Structure

- **Lead with purpose**: Start each section by stating what problem it solves or what question it answers, before diving into mechanism.
- **Layer detail progressively**: Start with the simplest correct explanation, then unfold complexity. A one-sentence intuition → a paragraph of mechanics → full formalization. Readers should be able to stop at any layer and still have a useful understanding.
- **Use bullet lists for buffer layouts and field descriptions**: Each bullet should name the field, state its size/dimensions, and explain its role. One field per bullet.
- **Use tables for comparisons**: When contrasting modes, phases, or alternatives (e.g., IPC vs Fabric, dispatch vs combine), a table makes differences scannable. Good tables show trade-off dimensions (latency vs bandwidth vs complexity), not just feature checklists.
- **Use quote blocks to pre-answer reader questions**: When a design choice would naturally prompt "why not X?", insert a callout block that raises and answers the question inline. This is especially valuable for interview preparation — it models the follow-up questions an interviewer would ask.
- **Use diagrams for spatial relationships and process flows**: Mermaid sequence diagrams are effective for multi-party protocols (sender/receiver timing, GPU→Host→Network stages). Mermaid graph diagrams work well for topology and architecture. Use them when the information has temporal ordering or spatial structure that text cannot convey efficiently.
- **Include a constraints and gotchas section for practical topics**: Explicitly document where things break, common mistakes, and the error model behind each gotcha — not just the fix. Structure as: mistake → why it happens → correct pattern.
- **Check internal consistency of diagrams and text.** If a page contains two representations of the same structure (e.g., a per-element diagram and an overall layout diagram), verify they agree on ordering, naming, and dimensions. A diagram that contradicts the text is worse than no diagram.

## Cross-Page Coherence

When a topic spans multiple pages (e.g., DeepEP overview + buffer + communication):

- **Define concepts once, reference thereafter.** If the channel mechanism is explained in buffer.md, communication.md should reference it, not re-explain.
- **Each page should have a clear scope** stated in its opening sentence. "This page analyzes kernel-level data flow" vs "This page covers buffer memory layout" prevents overlap.
- **Use relative links with annotations.** `[Buffer 架构](buffer.md) — NVLink/RDMA 缓冲区的内存布局` tells the reader whether to click.
- **Keep the section README index accurate.** After writing or rewriting a page, update the README.md table entry to reflect the actual content.

## Common Pitfalls to Avoid

1. **Listing struct fields without explaining them.** A code block showing a struct definition is not documentation. Each field needs at minimum: what it stores, who writes it, who reads it, and why.
2. **Using a term before defining it.** If you mention "channel" in one section, the reader must have already seen its definition. Audit your term dependencies.
3. **Writing a section that is only understandable if you already read the code.** Test: could a reader who has never seen the source code follow your explanation? If not, you are missing context.
4. **Assuming the reader knows which GPU or process a statement refers to.** In distributed systems documentation, ambiguous subjects ("it sends data") are a frequent source of confusion. Name the actor explicitly.
5. **Repeating explanations across sections.** If a concept (e.g., the channel queue mechanism) appears in multiple phases (dispatch, combine, internode), explain it fully once and reference it thereafter. Do not copy-paste the same paragraph with minor variations.
6. **Bare reference links.** Every link in a references section should have a short annotation explaining what the reader will find there. `https://arxiv.org/...` alone is useless; `Dao-AILab/flash-attention — reference implementation with benchmarks` tells the reader whether to click.
7. **Creating standalone sections when content should be integrated.** When adding a new topic (e.g., grouped top-k) to an existing page, the instinct is to create a `### New Topic` section. Instead, ask: does this concept naturally extend an existing section? If so, weave it in. Standalone sections break narrative flow and create repetition.
8. **Stub pages with < 30 lines.** A page shorter than 30 lines almost certainly fails self-containment. Either expand it to a substantive tutorial or merge its content into a parent page. A 16-line page with just a formula and a link is not a wiki page — it's a bookmark.
9. **Quoting code without adding insight.** A code block showing a struct definition or function signature is not documentation. If you include code, every snippet must be accompanied by explanation that the code alone does not convey.
10. **Building on an unverified architectural assumption.** If your mental model of the system is wrong (e.g., "one GPU proxies RDMA for the node" when actually all 8 GPUs send independently), every formula, diagram, and walkthrough built on that model will be wrong. Verify the core architectural claim against the code *before* writing the rest of the page. The cost of checking one assumption is minutes; the cost of propagating a wrong one is rewriting 5+ sections.
11. **Comparing numbers with different units across sections.** If one section says "2,048 servers" and another says "5,120 switches," a reader scanning the page will compare them as if they are the same quantity. When numbers from different contexts appear near each other, add an explicit comparison note clarifying what each number measures and how they relate (e.g., a side-by-side table with both metrics for the same configuration).
12. **Handwavy attribution.** "Prior work shows...", "it is well known that...", "recent studies suggest...", "many researchers believe..." without naming the specific work is not citation — it is filler. State the source by author and year (e.g., "Dao et al. 2022 (FlashAttention)") and the specific finding (numbers, dataset, condition). Never invent a citation: if you cannot verify the paper, remove the claim, soften it to your own observation with concrete evidence, or mark it `[UNVERIFIED]` for follow-up.
13. **Register drift via contractions.** In formal technical prose, prefer "it is" over "it's", "does not" over "doesn't", "cannot" over "can't". A single contraction in an otherwise formal paragraph reads as careless. Pick a register and hold it within the page.
14. **Title concept undefined.** If the paper or system name contains a key descriptive term (e.g., "Ragged" in Ragged Paged Attention), that term must be explicitly defined with a concrete example before the page is done — ideally in the opening section. The reader should never finish reading without knowing what the adjective in the title refers to.
15. **Paired operations left disconnected.** When one section describes an operation (e.g., merging K and V for DMA efficiency) and a later section describes its inverse (e.g., separating K and V for compute), explicitly cross-reference them. Without this, the reader sees a contradiction: "you said they were merged, now they're separate — which is it?" A single sentence or quote block reconciling the two (merged at DMA level, separated at compute level, overhead is low because...) prevents this.
16. **Parameters conflated across memory hierarchy levels.** When introducing configuration parameters that operate at different levels of the memory hierarchy (e.g., $b_q$ for HBM → VMEM DMA block size vs $c_q$ for VMEM → VREG compute block size), explicitly state which boundary each parameter crosses. Calling both "block size" without this distinction loses critical information about what physical operation each controls.
17. **Not providing a concrete example for an abstract layout transformation.** When describing a reshape or memory layout change (e.g., packing, tiling, transpose), follow the abstract description with a tiny concrete example using real dimensions. "(8, 128) BF16 → physically stored as (4, 128) 32-bit, where physical row 0 holds logical rows 0 and 1" makes the abstract rule tangible. The reader should be able to draw the before/after on paper.

## References

- [The Elements of Agent Style](https://github.com/yzhao062/agent-style/blob/main/RULES.md) — 21 writing rules (12 canonical, 9 field-observed) for AI-generated technical prose. Many of the bullets in *Tone and Style* and *Sentence and Paragraph Discipline* above are adapted from this ruleset.
