# StudioStreamer

Design and build-out project for Paul's studio streaming system: a split
production/streaming PC setup supporting private in-studio listening,
livestreaming, QR-code guest access, verified/limited-attendance access, and
interactive song-request workflows.

## Source of truth

`resources/studio_streaming_design_spec.md` is the high-level design spec and
the authoritative reference for architecture, requirements, and terminology.
Read it before proposing designs or naming components — reuse its section
numbers and vocabulary (e.g. "Verified Mode," "Guest Listening Mode") when
discussing or documenting decisions so outputs stay traceable back to spec
sections.

The spec is intentionally high-level (§1) and defers many choices to
"detailed design phase" (§14: exact PC specs, capture hardware, audio
interface routing, local-server-vs-cloud portal, login mechanism, network
vendor/switch, shared vs separate ingest chains, local-only vs
internet-capable, manual vs automated moderation). Work in this repo is
largely about resolving those open items one at a time.

## Repo layout

- `resources/` — reference material as given (spec docs, vendor datasheets,
  etc.). Treat as read-only source input; don't edit in place — if the spec
  changes, get an updated copy from the user rather than hand-editing this
  file.
- `docs/decisions/` — one file per resolved open design decision (e.g.
  `login-mechanism.md`, `pc-specs.md`), capturing the choice made and why.
  Maps to spec §14's open-items list.
- `docs/architecture/` — diagrams and topology docs (audio/video flow,
  network segmentation, system diagrams) elaborating spec §5, §8.
- `docs/hardware/` — production-PC and streaming-PC component specs/builds
  (spec §4).
- `docs/network/` — guest Wi-Fi, network segmentation, and access-control
  design (spec §8).

## Working conventions

- This is a hardware/network/systems design project, not primarily a
  software codebase — most "code" here will end up being config (OBS
  scenes, network/router config, captive portal setup, auth service config)
  and documentation rather than an application. Don't assume a build system.
- A Supabase MCP server is enabled for this project (see
  `.claude/settings.local.json`) — likely candidate backend for the
  verified-login portal, session/attendance tracking, and song-request
  workflows described in spec §6.2–§6.4. Confirm with the user before
  standing up real Supabase resources (branches, migrations) since those are
  shared/remote state.
- When a design decision is made, write it to `docs/decisions/` rather than
  only stating it in conversation, so future sessions don't need to
  re-derive it from chat history.
- Flag when a proposal touches Anti-Rebroadcast/Access Integrity (spec §9)
  or attendance limits (spec §6.3) since those have security/privacy
  implications (token expiry, rate limiting, watermarking).
