# High-Level Studio Streaming Design Spec

## 1. Purpose
Create a flexible studio streaming system that supports:
- private listening inside or near the studio
- livestreaming to the internet
- QR-code based access from guest Wi-Fi
- verified access for selected users
- attendance limits for special events
- song request workflows such as birthdays or special sessions
- future expansion without rebuilding the entire system

This spec is intentionally high level. It defines the architecture and operating modes so that detailed component selection can happen later.

## 2. Core Requirements
The system should support three major use cases:

1. **Local listening mode**
   - Visitors scan a QR code
   - They join a guest Wi-Fi network
   - They open a web page and listen to the session audio
   - Intended for nearby guests, clients, or people waiting outside the room

2. **Verified broadcast mode**
   - Users must sign in before listening or interacting
   - Access should be limited to real users as much as practical
   - Session access should be traceable and time-limited
   - Intended for private events, invite-only listening, or controlled participation

3. **Interactive event mode**
   - Users can request songs or submit participation prompts
   - Access can be restricted by invite, QR code, login, or attendance cap
   - Intended for birthdays, special sessions, listening parties, or fan-style events

## 3. Recommended System Architecture
The preferred design is a **split architecture**:

- **Production computer**: runs the DAW, recording, mixing, plugins, and studio playback
- **Streaming computer**: handles stream encoding, browser/page hosting, video compositing, login/session management, and outbound broadcast

This separation reduces the risk that a stream-related problem will interrupt recording or mixing.

### Why separate machines
- isolates the DAW from livestream instability
- avoids CPU/GPU contention
- simplifies troubleshooting
- improves reliability for long sessions
- allows the streaming system to evolve independently

A single computer can be used for early testing, but the long-term design should assume separate production and streaming roles.

## 4. High-Level Computer Streaming Specs

### 4.1 Production / DAW Computer
Primary purpose: audio production.

Suggested baseline capability:
- modern multi-core CPU
- 32 GB RAM minimum, 64 GB preferred for larger sessions
- fast NVMe storage for sessions and sample libraries
- quiet cooling
- stable ASIO/CoreAudio interface support
- enough I/O for multichannel recording and monitoring

Functional needs:
- low-latency audio
- plugin processing
- session recording
- cue mixes
- talkback routing
- export / bounce workflows

### 4.2 Streaming Computer
Primary purpose: encoding and distribution.

Suggested baseline capability:
- modern CPU with strong single-thread and multithread performance
- 32 GB RAM minimum
- NVIDIA-class GPU or equivalent hardware encoder support for efficient video encoding
- NVMe SSD for caching, local recording, and temp files
- quiet thermals and fan profile suitable for studio use
- multiple USB ports for capture devices, control surfaces, and peripherals

Functional needs:
- OBS or equivalent streaming software
- web page or portal hosting
- video capture from cameras or switcher
- audio ingest from the DAW or studio mixer
- local recording of stream output for backup
- browser-based access pages for listeners and verified users

### 4.3 Optional Dedicated Infrastructure
Depending on scale, the design may later include:
- a separate mini server for portal/authentication
- local media server for audio-only listening
- separate machine for NDI or camera management
- network-attached storage for archived recordings

## 5. Audio and Video Flow

### 5.1 Audio Flow
A practical topology is:

DAW / mixer -> stream mix output -> streaming computer -> listener portal -> phones / tablets / remote viewers

The stream mix should be separate from the main control-room mix when possible. That allows the broadcast mix to be tailored independently.

Recommended audio streams to consider later:
- main studio mix
- stream mix
- cue mix
- talkback mix
- room mic / ambient feed

### 5.2 Video Flow
Video can be handled independently of audio.

Potential inputs:
- camera(s)
- control-room screen capture
- slides / source computer capture
- ATEM or other switcher output

Potential outputs:
- live stream to online platforms
- local viewing page
- archived recordings
- event-specific private feeds

## 6. Access Modes

### 6.1 Guest Listening Mode
This is the simplest mode.

Workflow:
- QR code is posted near the studio entrance or waiting area
- user joins the guest Wi-Fi network
- browser opens to a local listening page or captive portal
- user presses play

This mode should be easy and low-friction.

### 6.2 Verified Mode
This mode requires identity gating of some kind.

Candidate verification methods:
- email one-time code
- SMS one-time code
- magic link sign-in
- invite-only account creation
- CAPTCHA plus login

Recommended principle: combine **something the user knows or receives** with **proof of active human interaction**.

### 6.3 Limited Attendance Mode
This mode caps access.

Rules can include:
- maximum concurrent listeners
- invite-only access
- one-time QR codes
- expiring tokens
- waitlist / queue behavior
- per-session seat limits

### 6.4 Interactive Request Mode
Users can submit requests, such as:
- birthday song requests
- “play this next” suggestions
- comments for the host
- event-specific polls

This mode should allow rules such as:
- requests only after login
- one request per session
- moderation before playback
- request limits by event or time window

## 7. QR Code Strategy
QR codes are useful for both access and event participation.

Potential QR code targets:
- guest Wi-Fi join information
- local listening portal
- verified login portal
- event-specific page
- song request page
- invite redemption page

Best practice is to make the QR code resolve to a **short URL or portal**, not to embed secrets directly.

### QR code goals
- reduce friction
- avoid typing URLs manually
- make access feel immediate
- allow printed cards, flyers, or signage to control entry

## 8. Guest Wi-Fi and Network Segmentation
The studio network should be separated by purpose.

Suggested logical segments:
- studio control network
- audio/AV network
- guest listening network
- IoT / cameras / auxiliary devices
- internet-facing services

This separation helps:
- protect studio equipment from guest devices
- reduce accidental access
- simplify troubleshooting
- support future expansion

A guest Wi-Fi network should be isolated from production devices except for the minimum required path to the listening portal.

## 9. Anti-Rebroadcast and Access Integrity
No practical system can make rebroadcasting impossible once a real person can hear the stream. The design should instead focus on making unauthorized redistribution harder and easier to trace.

Mitigation options:
- expiring stream tokens
- per-user unique session URLs
- short-lived access grants
- login-backed access rather than anonymous access
- rate limiting
- watermarking for video or on-screen overlays
- logging of session creation and access times
- local-only access when possible

For high-value private events, it may also be useful to:
- reduce the maximum session duration
- require periodic re-authentication
- limit the number of concurrent devices per account

## 10. Latency Targets
Latency depends on the mode.

Recommended targets:
- **guest listening**: low enough to feel near-real-time for casual listening
- **interactive verified mode**: low enough for song requests and basic participation
- **public livestream mode**: acceptable for external broadcast, even if more delayed

A local listening page should aim for much lower latency than a typical public livestream platform.

## 11. Streaming Software and Hosting
The streaming computer should be able to support:
- OBS Studio or equivalent
- audio capture from the DAW or mixer
- browser-based listener pages
- local portal pages for login and requests
- optional stream recording

Potential software services later:
- audio-only local server
- authenticated web portal
- captive portal for guest Wi-Fi
- stream management dashboard

## 12. Studio Room Integration
The studio’s physical design should support this system with:
- structured cabling
- technical network drops
- conduit paths to the control room and other spaces
- dedicated locations for stream hardware and network gear
- low-noise equipment placement

Any streaming or network equipment placed inside the studio should be selected with noise in mind so that fans, pumps, and power supplies do not compromise the room’s acoustic goals.

## 13. Expansion Path
The system should be designed so that later phases can add:
- additional cameras
- multi-room audio feeds
- WebRTC or low-latency media delivery
- event-specific landing pages
- automated invite generation
- better user analytics
- request moderation tools
- archival recording
- mobile-friendly event pages

## 14. Open Design Decisions for Later
These items can be resolved in the detailed design phase:
- exact PC specifications
- choice of capture hardware
- audio interface routing method
- local server vs cloud-hosted portal
- login mechanism for verified users
- preferred network vendor and switch model
- whether video and audio share the same ingest chain
- whether the system should be local-only or internet-capable
- whether request moderation is manual or automated

## 15. Summary
The studio should be designed as a modular broadcast environment with:
- a dedicated production computer
- a dedicated streaming computer
- guest Wi-Fi access by QR code
- a local listening page
- verified and limited-access modes
- interactive request capabilities
- controls that discourage rebroadcasting and unauthorized sharing

The long-term objective is a studio system that can operate as a private listening room, an invite-only broadcast platform, or a controlled event space without major redesign.

