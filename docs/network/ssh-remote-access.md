# Decision: SSH remote access to the Ubuntu host

**Status:** done (initial setup) — static IP reservation and password-auth
lockdown still open (see below)

## Context

One of the studio machines runs Ubuntu at `192.168.50.54` (hostname
`hotelstreamer`, kernel `7.0.0-30-generic`, x86_64). Role within the spec's
production/streaming split (§3) is not yet confirmed — update this doc once
that's decided.

We need to be able to administer this box remotely from the Windows
workstation instead of using its console each time.

## What was done

1. Installed and enabled the SSH server on the Ubuntu host:
   ```bash
   sudo apt update && sudo apt install -y openssh-server
   sudo systemctl enable --now ssh
   ```
   (Watch out for `apt install -t <pkg>` — `-t` is the target-release flag,
   not "yes"; it consumes the package name as an invalid release argument.
   Use `-y` to auto-confirm.)

2. If `ufw` is active, opened port 22 to the local subnet only:
   ```bash
   sudo ufw allow from 192.168.50.0/24 to any port 22 proto tcp
   ```

3. Generated a dedicated ed25519 keypair on the Windows side (following the
   existing per-device key convention used for the Bela boards):
   `~/.ssh/studiostreamer_id_ed25519` / `.pub`

4. Installed the public key into `paul@192.168.50.54`'s
   `~/.ssh/authorized_keys` (via a one-time password-authenticated `ssh`
   command run interactively).

5. Added an alias to `~/.ssh/config` on the Windows workstation:
   ```
   Host studiostreamer 192.168.50.54
       HostName 192.168.50.54
       User paul
       IdentityFile ~/.ssh/studiostreamer_id_ed25519
       IdentitiesOnly yes
   ```

Result: `ssh studiostreamer` logs in from the Windows machine with no
password prompt.

## Open items

- **Static IP / DHCP reservation**: `192.168.50.54` is not yet guaranteed
  stable. Reserve it by MAC address on the router/DHCP server so the SSH
  config alias and any future portal/streaming config referencing this IP
  don't break.
- **Disable password authentication**: once key-based login is confirmed
  reliable, set `PasswordAuthentication no` in `/etc/ssh/sshd_config` on the
  Ubuntu host and restart `ssh`, to close the brute-force surface entirely.
- **Confirm machine role**: determine whether this host is the production
  (DAW) computer or the streaming (encode/portal) computer per spec §4, and
  update this doc plus `docs/hardware/` accordingly.
- **Network segmentation** (spec §8): confirm which logical segment
  `192.168.50.0/24` corresponds to, and whether this host should eventually
  sit on a more restricted studio-control segment rather than the general
  LAN.
