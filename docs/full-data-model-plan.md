# Full Data Model Plan

This plan separates the data DjSwiftServer should own from the public response shapes it exposes. The current API models are a good listener contract, but they are not yet the complete source-of-truth model for authored station data, schedule publication, provider reconciliation, or admin operations.

Apple's platform boundary shapes the model. [Apple Music catalog song lookup](https://developer.apple.com/documentation/applemusicapi/get-a-catalog-song) is storefront-scoped, [Apple Music API supports ISRC lookup](https://developer.apple.com/documentation/applemusicapi/get-multiple-catalog-songs-by-isrc) for catalog songs, and MusicKit playback is client-owned through [`ApplicationMusicPlayer`](https://developer.apple.com/documentation/musickit/applicationmusicplayer) and [`PlayParameters`](https://developer.apple.com/documentation/musickit/playparameters). DjSwiftServer should publish timing intent and provider references, while the listener app owns authorization, storefront resolution, queue construction, playback, and drift recovery.

## Model Boundaries

### Authored Catalog

The authored catalog is the durable source of truth for station programming. It should be loadable from a package resource first, then later from admin-published snapshots or storage.

This model should own:

- station identity and branding
- show definitions
- host metadata
- reusable canonical tracks
- reusable voice breaks
- provider references attached to canonical tracks
- schedule windows or schedule blocks that reference authored entities by ID
- publication metadata such as revision, generated time, and validity range

It should not own listener account tokens, MusicKit user authorization, Music User Tokens, or client playback queue state.

### Public Listener API

The public listener API is a read-only projection of the authored catalog. It can denormalize data for client convenience, but it should not become the only source of truth.

This model should keep exposing:

- station manifest
- current schedule window
- explicit schedule windows
- show metadata
- voice-break metadata
- provider references needed by listener apps
- polling and cache guidance

### Admin and Import Models

Admin and import models are future write surfaces. They should stay separate from public listener routes so authentication, validation, and publishing rules do not leak into unauthenticated public API behavior.

Future write-side models should cover:

- draft shows
- draft schedules
- playlist imports
- voice-break uploads or generated-break records
- provider reconciliation results
- publication snapshots
- validation reports

## Proposed Source-of-Truth Types

### StationRecord

Represents one station that can publish listener data.

Fields:

- `id`
- `name`
- `tagline`
- `artworkURL`
- `defaultTimezone`
- `supportedProviders`
- `playbackPolicy`
- `links`

Open decisions:

- Whether `defaultTimezone` should be IANA-only from the beginning.
- Whether links should stay public-route-only or include future admin/media roots.

### PlaybackPolicyRecord

Holds station-level client guidance that should not be duplicated into each schedule.

Fields:

- `scheduleLookaheadSeconds`
- `prefetchBreakCount`
- `clockDriftToleranceSeconds`
- `clientPollIntervalSeconds`

Open decisions:

- Whether drift tolerance belongs station-wide, show-wide, or schedule-window-specific once real programming differs by show type.

### ShowRecord

Represents a reusable show definition.

Fields:

- `id`
- `title`
- `hostIDs`
- `summary`
- `artworkURL`
- `defaultDurationSeconds`
- `tags`

Open decisions:

- Whether host metadata should be a separate first-class `HostRecord` before there is more than one host.
- Whether recurring show rules belong here or in a separate programming calendar model.

### HostRecord

Represents a person, persona, or production identity attached to shows and breaks.

Fields:

- `id`
- `displayName`
- `summary`
- `avatarURL`
- `links`

Open decisions:

- Whether host records are needed now or whether a simple show `host` string is enough until admin surfaces exist.

### TrackRecord

Represents the canonical musical work or recording that schedule segments can reference.

Fields:

- `id`
- `title`
- `artistName`
- `albumTitle`
- `durationSeconds`
- `isExplicit`
- `isrc`
- `providerReferences`
- `metadataSource`
- `updatedAt`

Open decisions:

- Whether `id` should be local and stable, or derived from ISRC when present.
- Whether album/artist should stay string-shaped for now or become separate records later.
- Whether multiple recordings with the same title/artist should require explicit disambiguation fields.

### ProviderReferenceRecord

Represents a provider-specific way to resolve a canonical track.

Fields:

- `provider`
- `catalogID`
- `storefront`
- `isrc`
- `uri`
- `availability`
- `lastResolvedAt`
- `resolutionSource`

Provider rules:

- For Apple Music, `catalogID` is valid for the listed `storefront`.
- For Apple Music, `isrc` is the cross-storefront fallback.
- For Spotify, `uri` can carry the provider-native track reference later.
- `availability` describes confidence in the reference, not whether a listener is personally authorized to play it.

Open decisions:

- Whether to store one provider reference per storefront or one preferred reference plus ISRC fallback.
- Whether `lastResolvedAt` and `resolutionSource` wait until a real catalog reconciliation job exists.

### VoiceBreakRecord

Represents server-hosted non-music audio.

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
- `showID`
- `createdAt`
- `updatedAt`

Open decisions:

- Whether audio URLs should be stable public URLs, signed URLs, or storage keys projected to URLs at response time.
- Whether generated-break prompt metadata should be modeled now or delayed until generation exists.

### SchedulePublication

Represents one published schedule snapshot.

Fields:

- `id`
- `revision`
- `generatedAt`
- `validFrom`
- `validUntil`
- `segments`
- `source`

Rules:

- `revision` should change whenever future listener-visible schedule content changes.
- A publication is immutable once served, except for emergency replacement through a new revision.
- Public schedule responses are projections from this snapshot.

Open decisions:

- Whether `revision` should be timestamp-based, hash-based, or a monotonic sequence.
- Whether the first catalog resource should contain exactly one current publication or multiple future publications.

### ScheduleSegmentRecord

Represents one scheduled item in a publication.

Fields:

- `id`
- `sequence`
- `kind`
- `startsAt`
- `durationSeconds`
- `driftPolicy`
- `showID`
- `trackID`
- `voiceBreakID`
- `notes`

Rules:

- `trackID` is present for `track` segments.
- `voiceBreakID` is present for `voiceBreak`, `showIntro`, and `showOutro` segments when the segment is backed by server-hosted audio.
- Segment identity should stay stable within a publication revision.

Open decisions:

- Whether `showIntro` and `showOutro` should remain segment kinds or become voice-break roles.
- Whether ad, live, fallback, silence, or unavailable-track segment kinds need to be introduced before real scheduling.

## Projection Rules

The public response models should be generated from the source-of-truth records:

- `StationRecord` plus `PlaybackPolicyRecord` projects to `StationManifest`.
- `SchedulePublication` projects to `ScheduleResponse`.
- `ScheduleSegmentRecord` joins `TrackRecord` and `VoiceBreakRecord` into `ScheduleSegment`.
- `TrackRecord.providerReferences` projects into `TrackSegment.providerReferences`.
- `VoiceBreakRecord` projects to both `VoiceBreakReference` and `VoiceBreakDetail`.
- `ShowRecord` projects to `ShowMetadata`.

Projection code should stay explicit. The goal is readable transformations from authored data to public API data, not a broad generic mapper.

## Validation Rules

The loader for the first authored catalog resource should fail startup with descriptive errors when:

- IDs are duplicated within a record type.
- A schedule segment references a missing show, track, or voice break.
- A segment has neither a track nor a voice break when its kind requires one.
- Segment durations are zero or negative.
- Schedule windows have `validUntil <= validFrom`.
- Segment sequence values are duplicated or not sorted.
- Provider references do not include enough data for their availability state.
- Apple Music references with `catalogID` omit `storefront`.
- Voice-break checksums are missing or do not include an algorithm prefix.
- Public URLs are malformed.

These errors should name the record type, record ID, field, and likely fix.

## Implementation Phases

### Phase 1: Authored Catalog Resource

Status: Implemented for the bundled local catalog.

- Add a bundled JSON catalog resource under the executable target.
- Add source-of-truth record types separate from public response types.
- Load and validate the bundled catalog at startup.
- Keep public routes unchanged.
- Add tests for successful load and invalid fixture errors.

### Phase 2: Projection Layer

Status: Implemented for the current public listener API contract.

- Move public response construction out of `RadioCatalog.sample`.
- Add explicit projection functions from records to response models.
- Keep the public JSON contract stable.
- Add tests for projection behavior and schedule-window filtering.

### Phase 3: Import and Reconciliation Planning

- Define playlist-import input shape.
- Define provider reconciliation result shape.
- Decide whether Apple Music catalog lookup is a manual tool, a CLI command, or a server-side admin job.
- Keep listener account authorization out of the server.

### Phase 4: Storage Decision

- Decide whether the next source of truth is still JSON snapshots, SQLite, or another store.
- Add storage only when admin publishing, history, or multi-publication lookup makes file resources too limiting.

## Current Completeness

The public listener response model is complete enough for the current read-only API. The bundled source-of-truth catalog, validation rules, and projection layer now exist for local development. The broader product data model is still incomplete until import, provider reconciliation, admin publishing, and storage decisions are made.

The next implementation branch should start Phase 3 by deciding whether Apple Music catalog lookup is a manual tool, a CLI command, or a server-side admin job. Keep listener account authorization out of the server.

## References

- [Apple Music API](https://developer.apple.com/documentation/applemusicapi/)
- [Get a Catalog Song](https://developer.apple.com/documentation/applemusicapi/get-a-catalog-song)
- [Get Multiple Catalog Songs by ISRC](https://developer.apple.com/documentation/applemusicapi/get-multiple-catalog-songs-by-isrc)
- [ApplicationMusicPlayer](https://developer.apple.com/documentation/musickit/applicationmusicplayer)
- [PlayParameters](https://developer.apple.com/documentation/musickit/playparameters)
