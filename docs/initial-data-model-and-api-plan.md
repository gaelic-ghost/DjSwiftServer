# Initial Data Model and API Plan

DjSwiftServer is the schedule authority for an internet radio platform. It does not stream Apple Music or hold listener account credentials. The server publishes station metadata, schedule timing, show metadata, provider identifiers, and break audio metadata; the listener app resolves and plays music through the listener's own Apple Music account with MusicKit.

Apple's MusicKit model matters for the server shape. `ApplicationMusicPlayer` lets the client app play music for itself without taking over Music.app state, and its queue is built from playable music items. Apple Music API catalog data is storefront-specific, while user-library and user-specific requests require a Music User Token. On Apple platforms, MusicKit manages that token for the app. Because of that, DjSwiftServer should publish provider references and timing intent, while the client owns authorization, storefront resolution, queue construction, playback, and drift recovery.

## Product Role

DjSwiftServer provides read-only listening data for public clients:

- station identity and manifest metadata
- current and upcoming schedule windows
- show metadata
- track timing and provider resolution hints
- voice break metadata and audio locations
- polling and cache guidance for clients

Later authenticated admin APIs can publish schedules, manage shows, upload recorded breaks, trigger AI-generated breaks, and reconcile provider metadata. Those admin surfaces should stay separate from the public listener API.

## Modeling Principles

- Model the schedule as provider-neutral timing intent.
- Treat Apple Music as the first provider resolution, not as the identity of the scheduled track.
- Keep provider IDs beside canonical track metadata so Spotify can be added later without reshaping the schedule.
- Include `serverTime`, `generatedAt`, `validUntil`, and `revision` on schedule-like responses so clients can detect drift and stale data.
- Give every playable segment a stable `id`, `sequence`, `startsAt`, `durationSeconds`, and `driftPolicy`.
- Do not send listener-specific tokens, Apple Music user tokens, or private account data through DjSwiftServer.
- Make voice breaks cacheable media assets with enough metadata for prefetch, verification, captions, and loudness handling.

## Core Data Shapes

### Station Manifest

The manifest is the client's launch document. It tells the app what station it is connecting to, which API version is active, where the current schedule lives, which providers are supported, and how often to refresh.

Fields:

- `apiVersion`
- `station`
- `serverTime`
- `schedule`
- `playback`
- `supportedProviders`
- `links`

### Schedule

The schedule is an ordered timeline for a validity window. It can be fetched as the current window or by an explicit time range later.

Fields:

- `id`
- `revision`
- `generatedAt`
- `validFrom`
- `validUntil`
- `serverTime`
- `segments`

### Segment

A segment is one scheduled thing the listener app needs to play or account for. The first segment kinds are `track`, `voiceBreak`, `showIntro`, and `showOutro`. Future kinds may include `live`, `ad`, or `fallback`.

Fields:

- `id`
- `sequence`
- `kind`
- `startsAt`
- `durationSeconds`
- `driftPolicy`
- `showID`
- `track`
- `voiceBreak`

### Track Segment

A track segment describes the musical work and the provider-specific ways a client can resolve it.

Fields:

- `title`
- `artistName`
- `albumTitle`
- `durationSeconds`
- `isExplicit`
- `providerIDs`

Apple-first provider fields:

- `provider`
- `catalogID`
- `storefront`
- `isrc`
- `availability`

Spotify can later add a `spotify` provider entry with a Spotify ID or URI beside the Apple Music entry.

### Voice Break Segment

A voice break segment describes non-music audio that DjSwiftServer or a CDN can serve directly.

Fields:

- `id`
- `title`
- `audioURL`
- `mimeType`
- `durationSeconds`
- `checksum`
- `loudnessLUFS`
- `transcript`
- `provenance`

`provenance` starts with `recorded` and `aiGenerated`.

### Show

A show groups scheduled segments into a listener-visible block.

Fields:

- `id`
- `title`
- `host`
- `summary`
- `artworkURL`
- `startsAt`
- `endsAt`

## Public API Surface

The first public listener API should be read-only and cacheable:

```text
GET /v1/manifest
GET /v1/schedule/current
GET /v1/schedule?from=...&to=...
GET /v1/shows/{showID}
GET /v1/breaks/{breakID}
GET /v1/health
```

The branch skeleton implements static JSON responses for these routes so the client contract can settle before storage, publication tools, or provider lookup are added.

## Client Access Pattern

At launch:

- Fetch `/v1/manifest`.
- Fetch `/v1/schedule/current`.
- Resolve the current and next few track provider IDs with MusicKit.
- Prefetch the next few voice breaks.

During playback:

- Poll `/v1/schedule/current` every 30-60 seconds while listening.
- Poll `/v1/manifest` every 5-15 minutes or when the schedule revision changes.
- Use `serverTime` and segment `startsAt` values to calculate local clock offset.
- Replace future queue entries when the schedule `revision` changes.

Later:

- Consider Server-Sent Events or WebSockets only when live correction, emergency breaks, or real-time schedule changes need faster delivery than polling.

## Access and Caching

The public listener API can start unauthenticated. It should use normal HTTP caching, ETags, and rate limits. Voice break audio can use stable public CDN URLs or signed URLs depending on hosting and rights constraints.

Admin APIs should be authenticated from the beginning and should not share routing or authorization assumptions with the public listener API.

## First Implementation Pass

- Split app bootstrap from route registration.
- Add Codable response models for manifest, schedule, shows, tracks, provider IDs, and breaks.
- Add deterministic sample catalog data.
- Implement static JSON endpoints for the public listener API.
- Add tests for status codes and JSON response shapes.
- Keep persistence, provider lookup, MusicKit token handling, Spotify integration, and admin APIs out of this pass.

## References

- [Apple Music API](https://developer.apple.com/documentation/applemusicapi/)
- [User Authentication for MusicKit](https://developer.apple.com/documentation/applemusicapi/user_authentication_for_musickit)
- [ApplicationMusicPlayer](https://developer.apple.com/documentation/musickit/applicationmusicplayer)
- [MusicPlayer.Queue](https://developer.apple.com/documentation/musickit/musicplayer/queue)
- [PlayParameters](https://developer.apple.com/documentation/musickit/playparameters)
