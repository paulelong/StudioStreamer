# Design: Guest listening test signal (local network)

**Date:** 2026-08-31
**Status:** approved, ready for implementation planning
**Maps to spec:** §6.1 Guest Listening Mode, §4.3 (local media server), §7 (QR code strategy)

## Purpose

Build an end-to-end proof of concept for Guest Listening Mode using a
looped spoken test signal instead of real studio audio, so the full guest
flow can be validated before any real audio/video routing exists:

> Guest scans a QR code → phone joins the guest Wi-Fi → a listening page
> opens (or is one more scan away) → guest presses play and hears
> "Welcome to Paulys Hotel and Streaming Service" looping.

**Explicitly out of scope for this pass**: public/internet streaming
(spec's "verified broadcast" and "public livestream" modes), real studio
audio, video. This is local-network-only, audio-only, using synthetic
test content. Public streaming is a separate future exercise once this
local path is proven.

## Architecture

```
Piper TTS (one-time) → welcome.wav
        │
        ▼
ffmpeg (loop + encode) ──stream──▶ Icecast2 (mountpoint /welcome.mp3)
                                          │
                                          ▼
                          Nginx serving listen.html ──fetches──▶ <audio src="…/welcome.mp3">
                                          ▲
                                          │
        ASUS GT-AC5300 guest network ─────┘
        (Wi-Fi QR + Captive Portal → listen.html, + fallback QR direct to listen.html)
```

Everything runs on `studiostreamer` (192.168.50.54) except the guest
network / captive portal / QR configuration, which lives in the ASUS
router's admin UI.

## Components

### 1. Audio generation (one-time, not a running service)

- Install [Piper](https://github.com/rhasspy/piper) (offline neural TTS)
  and a voice model (e.g. `en_US-lessac-medium`).
- A small script (`scripts/generate-welcome-audio.sh` or similar, run on
  `studiostreamer`) synthesizes the line "Welcome to Paulys Hotel and
  Streaming Service" to `welcome.wav`, then uses `ffmpeg` to append a
  couple seconds of silence, producing `loop_unit.wav` — the file that
  actually gets looped, so the repeat doesn't sound jarring.
- This is a manual/scriptable step, not a persistent service. Re-run it
  if the wording changes.

### 2. Streaming server

- `icecast2` (Ubuntu package) provides the local media server called out
  in spec §4.3, running as its own systemd service on `studiostreamer`.
  Mountpoint: `/welcome.mp3`.
- An `ffmpeg` source client feeds the mountpoint continuously:
  `ffmpeg -re -stream_loop -1 -i loop_unit.wav -codec:a libmp3lame -b:a
  128k -content_type audio/mpeg icecast://source:<password>@localhost:8000/welcome.mp3`
- Runs as a `systemd --user` service (same pattern as the existing
  `xvfb`/`x11vnc`/`obs` services — see
  `docs/network/headless-obs-setup.md`), `Restart=always`, so it survives
  reboots and restarts itself if it dies.

### 3. Listening web page

- One static page, `listen.html`, served by `nginx` on port 80 (no port
  number for guests to type).
- Big "▶ Press Play" button plus an `<audio>` element pointed at
  `http://studiostreamer:8000/welcome.mp3` (or the IP, if local DNS isn't
  set up). Explicit tap-to-play rather than relying on autoplay, since
  most mobile browsers block autoplaying audio anyway — this also matches
  spec §6.1's "user presses play."

### 4. Guest network / QR

- ASUS GT-AC5300 (stock firmware) Guest Network feature creates the
  guest SSID; the router's admin UI generates a standard Wi-Fi-join QR
  code for it automatically — no custom work needed here.
- ASUS's Captive Portal feature (Guest Network > Captive Portal) is
  configured to redirect newly-joined guest devices to `listen.html`.
- **Fallback QR**: a second, independent QR code (generated via
  `qrencode`) encodes the `listen.html` URL directly. This exists because
  captive-portal auto-redirect (particularly iOS's sandboxed
  "Sign in to network" mini-browser) is inconsistent about redirect
  timing and media/autoplay handling across devices. If the captive
  portal flow doesn't fire cleanly, scanning the fallback QR gets a
  guest to the listening page directly.
- **Known risk**: guest networks are commonly isolated from the main LAN
  ("Access Intranet" off by default on ASUS). If so, guest devices won't
  be able to reach `studiostreamer` at all. Implementation must check
  this and either enable intranet access for the guest SSID or add a
  firewall rule permitting guest-subnet access to `studiostreamer` on
  ports 80 and 8000 specifically (not general LAN access).

## Testing plan

Verify bottom-up, adding guest-network complexity last:

1. Piper output sounds correct and clear.
2. Icecast stream plays via VLC or a browser directly on the normal LAN
   (`http://studiostreamer:8000/welcome.mp3`).
3. `listen.html` plays correctly when opened directly by IP from a phone
   already on the normal Wi-Fi (sanity check before touching the guest
   network at all).
4. Configure the ASUS guest network + captive portal; test scanning the
   Wi-Fi-join QR from a phone, confirm the captive portal redirect fires,
   confirm pressing Play actually plays audio.
5. Test the fallback QR path (direct scan to `listen.html`) independently
   of the captive portal.

## Error handling

- `ffmpeg`→Icecast source client: `Restart=always` in its systemd unit,
  so a crash (e.g. Icecast restarting) is self-healing.
- Icecast itself: relies on the distro package's own systemd unit
  (already enabled by `apt install`).
- No handling needed for concurrent listeners beyond Icecast's defaults —
  out of scope for this test (attendance limits are a separate, later
  spec §6.3 concern).

## Open follow-ups (not blocking this design)

- Local DNS/hostname for `studiostreamer` from the guest network, so the
  listening page URL doesn't need a raw IP (nice-to-have, not required).
- Whether the guest SSID should be its own VLAN/subnet for real isolation
  (spec §8) rather than sharing the main LAN subnet with intranet access
  carved out — deferred; today's goal is proving the end-to-end flow, not
  finalizing network segmentation.
- Public/internet streaming mode entirely deferred, per Purpose above.
