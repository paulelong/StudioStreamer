# Decision: Headless OBS on the streaming host

**Status:** done and verified across a reboot

## Context

`studiostreamer` (192.168.50.54, see [ssh-remote-access.md](ssh-remote-access.md))
normally runs with no monitor attached. The spec calls for OBS or equivalent
for encoding/distribution (§4.2, §11), but OBS is a Qt GUI app — it needs a
display server to render into, even though it doesn't need a physical
monitor. Goal: OBS running and controllable with no monitor ever attached,
while still allowing occasional visual access when needed (e.g. one-time
scene setup).

Hardware found on this host: Intel Raptor Lake-S UHD Graphics (no discrete
GPU). VAAPI hardware encode confirmed working via `vainfo` (H264
`EncSlice`/`EncSliceLP` entrypoints present through the Intel iHD driver) —
use OBS's QSV/VAAPI encoder, not x264 software encoding, for efficient
encoding per spec §4.2.

## What was done

1. **Packages** (`apt`): `obs-studio` (32.1.0, from `universe` — recent
   enough to bundle `obs-websocket` for remote control), `xvfb`, `x11vnc`,
   `intel-media-va-driver-non-free`, `vainfo`.

2. **Switched the host to a pure text-mode boot** — no display manager
   fighting over a display that isn't there:
   ```bash
   sudo systemctl set-default multi-user.target
   sudo systemctl disable --now gdm3
   ```
   A monitor + `sudo systemctl start gdm3` still works if the desktop is
   ever needed.

3. **Virtual display**: `Xvfb :99 -screen 0 1920x1080x24` running as a
   `systemd --user` service — a fully software framebuffer, independent of
   whether a monitor is physically connected.

4. **OBS** runs against `DISPLAY=:99` as a `systemd --user` service
   (`--disable-shutdown-check` to skip the "unclean shutdown" dialog that
   would otherwise block headless startup).

5. **x11vnc** bound to the same virtual display, `-localhost` only (not
   exposed on the LAN) — reach it via an SSH tunnel:
   ```bash
   ssh -L 5900:localhost:5900 studiostreamer
   # then point a VNC viewer at localhost:5900
   ```
   A random VNC password was generated locally via `x11vnc -storepasswd`
   and stored on the host at `~/.vnc/passwd` (0600). It was shown once in
   the setup session and is not recorded in this repo; retrieve/rotate it
   on-box if needed — it's a second factor behind the SSH tunnel, not the
   primary access control.

6. **Autostart without login**: `loginctl enable-linger paul` so the
   user's systemd instance (and therefore `xvfb`/`x11vnc`/`obs`
   `systemd --user` services, all `enable`d) starts at boot with no
   interactive session — confirmed by a full reboot: all three came up
   automatically at `multi-user.target`, no monitor, no login.

   Unit files live on the host at `~/.config/systemd/user/{xvfb,x11vnc,obs}.service`.

### Gotcha hit during setup

`x11vnc` auto-detects Wayland via the `WAYLAND_DISPLAY` env var and refuses
to run ("Wayland sessions are as of now only supported via -rawfb...") even
when `-display :99` (an X display) is given explicitly, if that env var is
present in the process environment. Fixed by wrapping the unit's
`ExecStart` with `env -u WAYLAND_DISPLAY -u XDG_SESSION_TYPE` to strip
leftover Wayland env vars inherited from the systemd user manager.

## Verification

- `vainfo` shows working H264 hardware encode entrypoints via the Intel
  iHD driver.
- All three services (`xvfb`, `x11vnc`, `obs`) reported `active` and OBS
  was capturing desktop audio via PulseAudio immediately after first
  start.
- Rebooted the host (`sudo reboot`) and confirmed, at `uptime` showing 0
  minutes since boot: `systemctl get-default` → `multi-user.target`,
  `gdm3` inactive, and all three services `active` with no login — the
  full headless path works end to end.

## Open items

- **Remote control of OBS** (start/stop stream, switch scenes) still needs
  to be wired up via `obs-websocket` — currently OBS just runs with
  whatever scene collection it has; no automation yet.
- **VNC password rotation / secrets handling**: current password lives
  only on the host filesystem. If multiple people need VNC access,
  consider a proper secrets story rather than a single shared password.
- **Scene/source configuration**: OBS is running with a default empty
  scene collection — actual studio scenes (camera, DAW audio ingest,
  overlays) are not yet configured.
- Same open items as [ssh-remote-access.md](ssh-remote-access.md): static
  IP reservation, confirming this host's role (production vs. streaming
  computer, spec §4), and network segmentation (spec §8).
