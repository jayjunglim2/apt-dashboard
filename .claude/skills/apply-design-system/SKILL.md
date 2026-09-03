---
name: apply-design-system
description: >-
  Apply this repo's design system (DESIGN.md — 원티드 Montage/WDS 기반 시맨틱 토큰) to any HTML/CSS
  in the apt-dashboard project. Use this whenever the user wants to restyle a page, build a new
  page/component/slide deck, "디자인 시스템 적용", "토큰으로 정리", "Montage 스타일로", clean up hardcoded
  colors, add dark mode, or make a new surface look consistent with index.html — even if they
  don't say "design system" explicitly. Also use it when reviewing a diff for design-token drift.
---

# Apply the design system

This project has a single source of truth for visual design: **[`DESIGN.md`](../../../DESIGN.md)** at the repo root.
It is a compact, Montage(WDS)-derived system: semantic color layers (`Background / Label / Line / Primary / Status / Fill`),
a 4px spacing scale, a radius scale, 3 elevation levels, and Wanted Sans typography.

Your job with this skill is to make a page or component **look like it belongs next to `index.html`** — same tokens,
same spacing rhythm, same type scale — and to leave no hardcoded hex or off-scale pixel values behind.

## When you start

1. **Read `DESIGN.md` fully.** It is short. The token table in §2–§6 is the contract; §7 gives component specs
   (chip, filter group, range, marker, popup, footer); §9 is the refactor checklist.
2. **Read the current `index.html`** `<style>` block. It already implements every token in `:root` plus a
   `@media (prefers-color-scheme: dark)` override. New work should copy that `:root` block verbatim rather than
   invent new values — one definition of `--primary-normal`, everywhere.
3. If the target file is new, start from the same `:root` + dark-mode token blocks as `index.html`.

## Rules that matter (and why)

- **Never write a raw color in a rule.** `color:#6b7280` becomes `color:var(--label-assistive)`. If a needed
  color has no token, add it to `:root` (and the dark block) with a semantic name — don't scatter the literal.
  This is what lets one edit re-theme the whole project and what makes dark mode free.
- **Name by role, not by value.** `--primary-normal`, not `--blue-500`. `--status-cautionary`, not `--orange`.
  A reader should know *what a color is for* from its name.
- **Spacing/radius come from the scale.** Use `var(--space-*)` / `var(--radius-*)`. An arbitrary `padding:11px`
  breaks the rhythm; pick the nearest step (`--space-4` = 10px or `--space-5` = 14px) unless there's a real reason.
- **Every surface that sets a background sets it from a token**, so it composites correctly on either theme.
  A transparent `body` borrows the host page's color — always `background:var(--bg-normal)` on `body`.
- **Status colors ≠ accent.** `--primary-*` is for interaction (selected, active, link). `--status-*` is for
  data meaning (여유/빠듯/없음 on the map). Don't reach for primary blue to mean "good".
- **Match `index.html`'s component specs.** A chip here is `--radius-pill`, `min-height:28px`, `--primary-normal`
  when `.on`. A filter-group heading is `--type-heading` in `--label-assistive`, uppercase. Reuse, don't redesign.
- **Keep the CDN budget.** `index.html` loads Leaflet + Wanted Sans. Don't add font/CSS CDNs beyond that; if a
  surface can't use the Wanted Sans CDN (e.g. a published Artifact, where CSP blocks jsdelivr), fall back to
  `"IBM Plex Sans KR"` from Google Fonts plus the system stack in `--font-sans`.

## Workflow

1. Apply tokens to the target file following `DESIGN.md` §9 checklist. If you rename `:root` variables, update
   every `var(--old)` reference **including inside `<script>`** (e.g. `colorFor()` returns `var(--status-none)`,
   legend swatches use inline `style="background:var(--status-positive)"`).
2. Run the audit to catch anything missed:
   ```bash
   powershell -ExecutionPolicy Bypass -File .claude/skills/apply-design-system/scripts/audit-tokens.ps1 <file.html>
   ```
   It flags raw hex/`rgb()` colors in rules and pixel values that aren't on the 4px scale. Zero findings (outside
   the `:root` token definitions themselves) is the goal.
3. Verify visually. If a dev server config exists (`.claude/launch.json` → `apt-dashboard`), start the preview,
   load the page, screenshot it, and check both themes with `resize_window`'s `colorScheme`. Confirm no console
   errors and that Wanted Sans actually loaded (headings shouldn't fall back to a serif).
4. If `DESIGN.md` itself gained a token or rule during the work, update `DESIGN.md` so it stays the source of truth.

## Building a new slide deck / standalone page

Same tokens, but treat it as its own surface: copy the full `:root` + `@media (prefers-color-scheme: dark)` +
`:root[data-theme="dark"]` token blocks from `index.html` into the new file's `<style>`, then compose with
`var(--*)` only. A deck published as a Claude Artifact must inline or Google-Fonts its typography (CSP blocks
jsdelivr) — use the `--font-sans` fallback note above.
