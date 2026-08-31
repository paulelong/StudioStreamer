# Decision: Audio ingest for the streaming PC

**Status:** decided (plan of record) — maps to spec §14 open item "audio
interface routing method" and §5.1 (stream mix)

## Decision

The streaming PC (`studiostreamer`, see [../hardware/streaming-pc.md](../hardware/streaming-pc.md))
will receive its audio feed via a **Focusrite Scarlett 6i6** connected
directly over **USB**.

## Context

Other options considered and ruled out for this specific box:

- **Motherboard onboard optical ("lightpipe") between the two PCs** — dead
  end on both ends: the streaming PC's onboard codec (Realtek ALC897) is
  optical-**output**-only with no digital input at all, and the production
  PC's DAW mix renders through its audio interface's driver, not through
  Windows' onboard sound device, so nothing would even reach that port.
- **PreSonus 16R over USB or AVB** and **RME 12Mic over USB, ADAT, or
  MADI** — both are more capable (16 and 12 discrete channels
  respectively) and both are already committed elsewhere in the studio's
  signal chain: the 12Mic feeds the DAW via AVB through an RME Digiface
  AVB, and the 16R is on the same AVB network. Either could in principle
  also feed the streaming PC (16R supports independently-routed
  simultaneous USB + AVB output), but that's more setup than needed right
  now given the Scarlett is available.
- **AVB into the Linux streaming PC directly** — ruled out generally: no
  practical Linux driver support for RME's or PreSonus's AVB stacks (both
  rely on proprietary Windows/Mac drivers). Not pursued for this or any
  other interface.

## Notes / open follow-ups

- The 6i6 is an older generation (Gen 1 or Gen 2 — back panel not yet
  confirmed) with **coaxial S/PDIF** digital I/O, not optical. Its analog
  I/O and USB audio class functionality are unaffected by this; it only
  matters if a digital connection to/from the 6i6 is wanted later.
- As a USB-audio-class device, the 6i6 should work with the streaming
  PC's kernel (`7.0.0-30-generic`) via plain ALSA/PulseAudio with no extra
  driver — same conclusion reached for Focusrite interfaces generally in
  [../hardware/streaming-pc.md](../hardware/streaming-pc.md)'s research;
  not yet verified with this specific unit plugged in.
- Video ingest (camera/switcher) is a separate, still-open decision —
  leaning toward NDI over Ethernet per spec §4.3, not yet finalized.
