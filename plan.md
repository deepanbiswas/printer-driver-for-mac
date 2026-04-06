# Implementation plan — Canon PIXMA G3010 macOS driver

This document is the **executable plan** for building the driver described in [`spec.md`](spec.md). Work follows **Spec-Driven Development (SDD)**: requirements live in the spec; this plan turns them into iterations, acceptance criteria, and test expectations. Implementation follows **Test-Driven Development (TDD)**: tests define behavior before production code within each iteration.

---

## Project constraints (stakeholder decisions)

| Topic | Decision |
|--------|----------|
| **Hardware** | A **Canon PIXMA G3010** is available on the LAN for integration testing and visual/color sign-off. |
| **Protocol** | **Reverse engineering** of the wire protocol (within personal, lawful use) is **allowed**; no requirement to use only vendor SDKs. |
| **Distribution** | **Strictly personal use** — not intended for public release or commercial distribution. Packaging and signing can stay minimal (e.g. local install); notarization is optional unless macOS blocks installation on your machine. |
| **macOS version** | **macOS Tahoe compatibility is mandatory.** Development and validation target **Tahoe only** (e.g. Mac mini). No Sonoma test matrix. |
| **Color quality** | Start with **visual sign-off** against reference prints. **Numeric targets (e.g. ΔE)** are a **nice-to-have** for a later hardening pass, not a gate for early iterations. |

These choices tighten Iteration 0 (fixtures on real hardware), relax Iteration 8 (packaging/signing scope), and adjust Iteration 5 (visual-first acceptance).

---

## Tech stack

| Layer | Choice | Notes |
|--------|--------|--------|
| Print integration | **CUPS** — PPD + filter(s) | Native Print dialog; aligns with spec §8. |
| Core implementation | **C / C++** with **libcups** | Standard for CUPS filters; Apple Silicon friendly. |
| Color / grayscale | **lcms2** (and system ColorSync where appropriate) | Supports ICC workflows; tune for §4.3. |
| Networking | **BSD sockets** (TCP; port from discovery) | §4.5 — IP-based Wi‑Fi. |
| Build | **CMake** or **Xcode** + **clang** | Pick one; stay consistent. |
| Unit / integration tests | **GoogleTest** or **Catch2** + **golden-file** tests for encoded payloads | TDD on logic; mocks for network. |
| Installer (when needed) | **`pkgbuild` / `productbuild`** | Personal install; sign if Gatekeeper requires it. |
| Diagnostics | **os_log** and/or file logging under user-accessible logs | §5.5 — no secrets in logs (§5.4). |

---

## Repository layout (SDD / TDD)

| Path | Purpose |
|------|---------|
| [`spec.md`](spec.md) | **Single source of requirements** — changes here drive spec deltas and tests. |
| [`plan.md`](plan.md) | **This file** — iterations, acceptance criteria, process. |
| `docs/` | Architecture notes, protocol findings, iteration retrospectives, visual sign-off checklists. |
| `src/` | CUPS filters, protocol encoder, networking, color pipeline — **production code only**. |
| `tests/` | Unit tests, golden files, mocks — **no production code**. |
| `ppd/` | PPD files and related driver descriptors. |
| `filters/` | Optional: filter entrypoints if not colocated under `src/` (or merge into `src/` — keep one clear convention). |
| `packaging/` | Scripts and resources for `.pkg` or local install (personal use). |
| `fixtures/` | Captured hex/pcap-derived test vectors (no copyrighted blobs if avoidable; prefer synthetic or minimal captures). |

**SDD workflow:** Change `spec.md` → update acceptance tests / plan slice if needed → implement.  
**TDD workflow:** Red → green → refactor within each iteration’s scope; no feature “done” without tests for that scope.

---

## Iterations

### Iteration 0 — Discovery & protocol baseline (spike)

**Goal:** Establish enough understanding of how the printer accepts jobs to drive automated fixtures and architecture.

**Included**

- Capture and document **ports, framing, and minimal successful job** (personal device, lawful reverse engineering).
- Produce **reproducible fixtures** (golden blobs or mock server scripts) for “printer accepts job.”
- Short **architecture note** in `docs/` (protocol assumptions, risks, open questions).
- Confirm **PPD + `cupsFilter` graph** (what enters your filter).

**Acceptance criteria**

- `docs/` contains an architecture/discovery summary tied to spec sections.
- At least one **automated test** consumes a fixture without a physical printer (mock or golden decode).
- Team (you) agrees on **TDD boundaries**: what is always mocked vs. requires hardware smoke tests.

---

### Iteration 1 — Toolchain, CI, empty driver shell

**Goal:** Buildable project on **Tahoe** / Apple Silicon, CI running tests, visible queue with stub behavior.

**Included**

- Repo builds cleanly; **CI** runs build + unit tests on every push.
- Stub **CUPS filter** (reads stdin, exits success; no real print yet).
- Minimal **PPD** pointing at the filter.

**Acceptance criteria**

- CI green on default branch.
- Manual install of PPD + filter (developer procedure documented in `docs/`) shows a **printer queue** in the Print dialog on **Tahoe** (job need not physically print).

---

### Iteration 2 — Network transport (TDD)

**Goal:** Reliable, testable communication to printer IP with clear error behavior.

**Included**

- Connect / send / receive / timeout APIs.
- Mapping to spec **§4.6** (offline, unreachable, transmission failure) at the API level.
- Tests against a **mock TCP server**; no proprietary payload required yet.

**Acceptance criteria**

- Unit tests cover success, timeout, connection refused, partial failure paths.
- **No crashes** on invalid inputs.
- **Dynamic IP** documented as **manual queue update** (spec §4.5).

---

### Iteration 3 — First real print (hardware)

**Goal:** One visible page from a real G3010 using the discovered minimal job format.

**Included**

- Implement smallest end-to-end path using **fixtures from Iteration 0**.
- Hardware smoke procedure documented (when to run on device vs. CI-only).

**Acceptance criteria**

- A job from the test queue produces **visible output** on paper (personal G3010).
- CI still passes **without** printer (fixtures + mocks).
- Known limitations listed (e.g. fixed size/quality) if any.

---

### Iteration 4 — Print dialog options & job controls (TDD)

**Goal:** Map spec **§4.2** to PPD options and internal parameters.

**Included**

- Page sizes: **A4, Letter**; orientation: **portrait, landscape**.
- **Color** vs **black & white** (B&W must avoid color ink when protocol allows — document gap if undetectable).
- Quality: **draft / standard / high**.
- **Copies**, **scaling (fit to page)**, **page ranges**, **odd/even only**.
- Table-driven tests: option combinations → encoder parameters (golden expectations).

**Acceptance criteria**

- Options appear in Print dialog and change encoded parameters (verified by tests).
- B&W behavior documented; protocol flags wired where known.

---

### Iteration 5 — Color & grayscale (visual sign-off first)

**Goal:** Meet **§4.3** with **visual sign-off** as the primary gate; numeric ΔE optional later.

**Included**

- Color pipeline (ICC / intent) and grayscale path favoring **black** where possible.
- **Visual checklist** and reference prints (documented in `docs/`, e.g. photos or scanned comparisons as you prefer).
- Optional: reserve hooks for future **ΔE** regression tests (nice-to-have).

**Acceptance criteria**

- Stakeholder visual sign-off: **no objectionable systematic hue shifts** vs reference; grayscale acceptable as “true enough” B&W for personal use.
- Repeat prints look consistent to visual inspection.
- If numeric metrics are deferred, **plan.md / docs** state that explicitly.

---

### Iteration 6 — Multi-page, large jobs, PDF-heavy paths

**Goal:** **§4.4** and **§5.1** — robust handling of length and common app paths.

**Included**

- Multi-page stress tests; large PDF / raster pages.
- Memory/time behavior; streaming if needed.

**Acceptance criteria**

- Large document test completes without OOM or hang.
- Page order, ranges, odd/even behavior correct at filter level (automated tests).

---

### Iteration 7 — Errors, resilience, logging

**Goal:** **§4.6**, **§5.2**, **§5.5** — graceful failure and supportability.

**Included**

- User-visible failure behavior via CUPS / job status.
- Retry policy for transient network issues; clear failure when permanent.
- Logging levels; **no unnecessary exposure** of sensitive data (§5.4).

**Acceptance criteria**

- Simulated failures yield **meaningful** errors (not silent drop).
- Fault-injection / fuzz tests: **no crashes** in filter and network layer.

---

### Iteration 8 — Install packaging (personal use)

**Goal:** **§6** — repeatable install on your Mac(s) without developer-only steps.

**Included**

- Install script or `.pkg` that installs PPD + filters and registers the queue.
- **Personal use** scope: signing only if required for your Tahoe machine.

**Acceptance criteria**

- Clean install on **Mac mini (Tahoe)**; printer appears in Print dialog after install.
- Document uninstall / upgrade steps for personal maintenance.

---

### Iteration 9 — Spec completion & hardening

**Goal:** Match **§10** and close known gaps.

**Included**

- Full pass against **global acceptance** in `spec.md` §10.
- Soak / repeated print reliability.
- Update `spec.md` / `plan.md` only if reality required small requirement adjustments (SDD honesty).

**Acceptance criteria**

- All **§10** bullets satisfied on **your Tahoe Mac mini** with the personal G3010.
- Remaining risks from **§9** documented with mitigations or accepted limitations.

---

## Tahoe-only test matrix

| Environment | Role |
|-------------|------|
| **Mac mini — macOS Tahoe** | Primary and **only** required validation OS for releases you care about. |

Add CI on a **Tahoe** runner if available later; otherwise rely on local CI for build/tests and **manual** Tahoe validation for integration.

---

## Personal-use disclaimer

This driver is for **personal use on your own hardware** only. Reverse engineering and use of the software must comply with applicable laws and licenses. No warranty or redistribution is implied by this repository.

---

## Document history

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-04-06 | Initial plan from spec + stakeholder answers |
