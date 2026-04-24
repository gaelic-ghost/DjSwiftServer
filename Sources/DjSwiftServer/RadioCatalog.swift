import Foundation

struct RadioCatalog {
    var health: @Sendable () -> HealthResponse
    var manifest: @Sendable () -> StationManifest
    var currentSchedule: @Sendable () -> ScheduleResponse
    var show: @Sendable (_ id: String) -> ShowMetadata?
    var voiceBreak: @Sendable (_ id: String) -> VoiceBreakDetail?
}

extension RadioCatalog {
    static let sample: Self = {
        let generatedAt = Date.iso8601("2026-04-24T16:00:00Z")
        let validFrom = Date.iso8601("2026-04-24T16:00:00Z")
        let validUntil = Date.iso8601("2026-04-24T18:00:00Z")
        let serverTime = Date.iso8601("2026-04-24T16:05:00Z")
        let show = ShowMetadata(
            id: "show-friday-signal",
            title: "Friday Signal",
            host: "Gale",
            summary: "A first scheduled block for testing synchronized music and voice breaks.",
            artworkURL: "https://dj.example.invalid/artwork/friday-signal.png",
            startsAt: validFrom,
            endsAt: validUntil,
        )
        let introBreak = VoiceBreakReference(
            id: "break-friday-signal-intro",
            title: "Friday Signal Intro",
            audioURL: "https://dj.example.invalid/audio/breaks/friday-signal-intro.m4a",
            mimeType: "audio/mp4",
            durationSeconds: 22,
            checksum: "sha256:sample-intro-break",
            loudnessLUFS: -16.0,
            transcript: "You are tuned to Friday Signal.",
            provenance: .recorded,
        )
        let middleBreak = VoiceBreakReference(
            id: "break-friday-signal-reset",
            title: "Friday Signal Reset",
            audioURL: "https://dj.example.invalid/audio/breaks/friday-signal-reset.m4a",
            mimeType: "audio/mp4",
            durationSeconds: 18,
            checksum: "sha256:sample-reset-break",
            loudnessLUFS: -16.0,
            transcript: "A quick reset before the next track.",
            provenance: .aiGenerated,
        )
        let schedule = ScheduleResponse(
            id: "schedule-2026-04-24-friday-signal",
            revision: "2026-04-24T16:00:00Z-sample",
            generatedAt: generatedAt,
            validFrom: validFrom,
            validUntil: validUntil,
            serverTime: serverTime,
            segments: [
                ScheduleSegment(
                    id: "seg-0001",
                    sequence: 1,
                    kind: .showIntro,
                    startsAt: Date.iso8601("2026-04-24T16:00:00Z"),
                    durationSeconds: introBreak.durationSeconds,
                    driftPolicy: .anchorToWallClock,
                    showID: show.id,
                    track: nil,
                    voiceBreak: introBreak,
                ),
                ScheduleSegment(
                    id: "seg-0002",
                    sequence: 2,
                    kind: .track,
                    startsAt: Date.iso8601("2026-04-24T16:00:22Z"),
                    durationSeconds: 214,
                    driftPolicy: .preserveRelativeOffset,
                    showID: show.id,
                    track: TrackSegment(
                        title: "Midnight City",
                        artistName: "M83",
                        albumTitle: "Hurry Up, We're Dreaming",
                        durationSeconds: 214,
                        isExplicit: false,
                        providerIDs: [
                            ProviderResolution(
                                provider: .appleMusic,
                                catalogID: "666284200",
                                storefront: "us",
                                isrc: "FRS631100012",
                                uri: nil,
                                availability: .resolved,
                            ),
                            ProviderResolution(
                                provider: .spotify,
                                catalogID: nil,
                                storefront: nil,
                                isrc: "FRS631100012",
                                uri: nil,
                                availability: .needsStorefrontResolution,
                            ),
                        ],
                    ),
                    voiceBreak: nil,
                ),
                ScheduleSegment(
                    id: "seg-0003",
                    sequence: 3,
                    kind: .voiceBreak,
                    startsAt: Date.iso8601("2026-04-24T16:03:56Z"),
                    durationSeconds: middleBreak.durationSeconds,
                    driftPolicy: .skipIfLate,
                    showID: show.id,
                    track: nil,
                    voiceBreak: middleBreak,
                ),
            ],
        )
        let breaks = [
            introBreak.id: VoiceBreakDetail(
                breakInfo: introBreak,
                showID: show.id,
                createdAt: generatedAt,
                updatedAt: generatedAt,
            ),
            middleBreak.id: VoiceBreakDetail(
                breakInfo: middleBreak,
                showID: show.id,
                createdAt: generatedAt,
                updatedAt: generatedAt,
            ),
        ]

        return RadioCatalog(
            health: {
                HealthResponse(status: "ok", serverTime: serverTime, apiVersion: "v1")
            },
            manifest: {
                StationManifest(
                    apiVersion: "v1",
                    station: StationIdentity(
                        id: "dj-radio",
                        name: "DJ Radio",
                        tagline: "Scheduled music and voice breaks, played from the listener's account.",
                        artworkURL: "https://dj.example.invalid/artwork/station.png",
                    ),
                    serverTime: serverTime,
                    schedule: ScheduleReference(
                        currentURL: "/v1/schedule/current",
                        validFrom: validFrom,
                        validUntil: validUntil,
                        revision: schedule.revision,
                        pollIntervalSeconds: 60,
                    ),
                    playback: PlaybackGuidance(
                        scheduleLookaheadSeconds: 7200,
                        prefetchBreakCount: 3,
                        clockDriftToleranceSeconds: 2,
                        clientPollIntervalSeconds: 45,
                    ),
                    supportedProviders: [.appleMusic, .spotify],
                    links: ManifestLinks(
                        scheduleCurrent: "/v1/schedule/current",
                        scheduleWindow: "/v1/schedule",
                        health: "/v1/health",
                    ),
                )
            },
            currentSchedule: {
                schedule
            },
            show: { id in
                id == show.id ? show : nil
            },
            voiceBreak: { id in
                breaks[id]
            },
        )
    }()
}

private extension Date {
    static func iso8601(_ string: String) -> Date {
        guard let date = ISO8601DateFormatter().date(from: string) else {
            preconditionFailure("Invalid static ISO 8601 date: \(string)")
        }

        return date
    }
}
