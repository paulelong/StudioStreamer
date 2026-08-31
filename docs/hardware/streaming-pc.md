# Streaming PC: hardware spec

Maps to spec §4.2 (Streaming Computer). Network/access setup for this box is
in `docs/network/`.

| Item | Value |
|---|---|
| Hostname | `hotelstreamer` (SSH alias: `studiostreamer`) |
| LAN IP | 192.168.50.54 (not yet static/reserved — see [ssh-remote-access.md](../network/ssh-remote-access.md) open items) |
| Motherboard | MSI B760 GAMING PLUS WIFI (LGA 1700) |
| CPU | Intel Core i5-14400 (Raptor Lake, 10-core: 6P+4E), 65W |
| GPU | Intel UHD Graphics (iGPU, Raptor Lake-S) — no discrete GPU |
| RAM | 32 GB |
| OS | Ubuntu 26.04 LTS ("resolute"), headless (`multi-user.target`, no display manager) |

## Notes

- Meets the spec's 32 GB minimum for the streaming role (§4.2); no headroom
  above minimum, so watch RAM usage if adding more OBS sources/plugins or
  running additional services on this box.
- No discrete GPU — hardware video encode relies on the iGPU's Quick Sync
  (VAAPI) rather than NVENC. Confirmed working (`vainfo` shows H264
  `EncSlice`/`EncSliceLP` entrypoints via the Intel iHD driver) — use OBS's
  QSV/VAAPI encoder, not x264 software encoding. See
  [headless-obs-setup.md](../network/headless-obs-setup.md).
- 10 cores (6P+4E) gives reasonable headroom for encoding + web/portal
  hosting + any local recording concurrently, but this hasn't been
  load-tested under a real multi-source OBS scene yet.
