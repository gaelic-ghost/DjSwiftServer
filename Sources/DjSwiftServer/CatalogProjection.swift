import Foundation

extension RadioCatalog {
    static func bundled() throws -> Self {
        try AuthoredCatalogLoader.loadBundledCatalog().radioCatalog()
    }
}

extension AuthoredCatalog {
    func radioCatalog() throws -> RadioCatalog {
        try validate()

        let currentPublication = try currentPublication()
        let showIndex = Dictionary(uniqueKeysWithValues: shows.map { ($0.id, $0) })
        let hostIndex = Dictionary(uniqueKeysWithValues: hosts.map { ($0.id, $0) })
        let trackIndex = Dictionary(uniqueKeysWithValues: tracks.map { ($0.id, $0) })
        let voiceBreakIndex = Dictionary(uniqueKeysWithValues: voiceBreaks.map { ($0.id, $0) })
        let voiceBreakDetails = Dictionary(
            uniqueKeysWithValues: voiceBreaks.map { record in
                (
                    record.id,
                    record.voiceBreakDetail(),
                )
            },
        )

        let currentSchedule = currentPublication.scheduleResponse(
            trackIndex: trackIndex,
            voiceBreakIndex: voiceBreakIndex,
        )

        return RadioCatalog(
            health: {
                HealthResponse(
                    status: "ok",
                    serverTime: currentPublication.generatedAt,
                    apiVersion: "v1",
                )
            },
            manifest: {
                station.stationManifest(publication: currentPublication)
            },
            currentSchedule: {
                currentSchedule
            },
            schedule: { window in
                currentSchedule.filtered(to: window)
            },
            show: { id in
                guard let show = showIndex[id] else {
                    return nil
                }

                return show.showMetadata(
                    hostIndex: hostIndex,
                    publication: currentPublication,
                )
            },
            voiceBreak: { id in
                voiceBreakDetails[id]
            },
        )
    }

    private func currentPublication() throws -> SchedulePublicationRecord {
        guard let publication = publications.first(where: { $0.id == currentPublicationID }) else {
            throw CatalogValidationIssue(
                recordType: "AuthoredCatalog",
                recordID: currentPublicationID,
                field: "currentPublicationID",
                message: "No publication exists with this ID.",
                likelyFix: "Set currentPublicationID to an ID from publications.",
            )
        }

        return publication
    }
}

private extension StationRecord {
    func stationManifest(publication: SchedulePublicationRecord) -> StationManifest {
        StationManifest(
            apiVersion: "v1",
            station: StationIdentity(
                id: id,
                name: name,
                tagline: tagline,
                artworkURL: artworkURL,
            ),
            serverTime: publication.generatedAt,
            schedule: ScheduleReference(
                currentURL: links.scheduleCurrent,
                validFrom: publication.validFrom,
                validUntil: publication.validUntil,
                revision: publication.revision,
                pollIntervalSeconds: playbackPolicy.clientPollIntervalSeconds,
            ),
            playback: PlaybackGuidance(
                scheduleLookaheadSeconds: playbackPolicy.scheduleLookaheadSeconds,
                prefetchBreakCount: playbackPolicy.prefetchBreakCount,
                clockDriftToleranceSeconds: playbackPolicy.clockDriftToleranceSeconds,
                clientPollIntervalSeconds: playbackPolicy.clientPollIntervalSeconds,
            ),
            supportedProviders: supportedProviders,
            links: links,
        )
    }
}

private extension SchedulePublicationRecord {
    func scheduleResponse(
        trackIndex: [String: TrackRecord],
        voiceBreakIndex: [String: VoiceBreakRecord],
    ) -> ScheduleResponse {
        ScheduleResponse(
            id: id,
            revision: revision,
            generatedAt: generatedAt,
            validFrom: validFrom,
            validUntil: validUntil,
            serverTime: generatedAt,
            segments: segments.map { segment in
                segment.scheduleSegment(
                    trackIndex: trackIndex,
                    voiceBreakIndex: voiceBreakIndex,
                )
            },
        )
    }
}

private extension ScheduleSegmentRecord {
    func scheduleSegment(
        trackIndex: [String: TrackRecord],
        voiceBreakIndex: [String: VoiceBreakRecord],
    ) -> ScheduleSegment {
        ScheduleSegment(
            id: id,
            sequence: sequence,
            kind: kind,
            startsAt: startsAt,
            durationSeconds: durationSeconds,
            driftPolicy: driftPolicy,
            showID: showID,
            track: trackID.flatMap { trackIndex[$0]?.trackSegment() },
            voiceBreak: voiceBreakID.flatMap { voiceBreakIndex[$0]?.voiceBreakReference() },
        )
    }
}

private extension TrackRecord {
    func trackSegment() -> TrackSegment {
        TrackSegment(
            title: title,
            artistName: artistName,
            albumTitle: albumTitle,
            durationSeconds: durationSeconds,
            isExplicit: isExplicit,
            providerReferences: providerReferences.map(\.providerReference),
        )
    }
}

private extension ProviderReferenceRecord {
    var providerReference: ProviderReference {
        ProviderReference(
            provider: provider,
            catalogID: catalogID,
            storefront: storefront,
            isrc: isrc,
            uri: uri,
            availability: availability,
        )
    }
}

private extension VoiceBreakRecord {
    func voiceBreakReference() -> VoiceBreakReference {
        VoiceBreakReference(
            id: id,
            title: title,
            audioURL: audioURL,
            mimeType: mimeType,
            durationSeconds: durationSeconds,
            checksum: checksum,
            loudnessLUFS: loudnessLUFS,
            transcript: transcript,
            provenance: provenance,
        )
    }

    func voiceBreakDetail() -> VoiceBreakDetail {
        VoiceBreakDetail(
            breakInfo: voiceBreakReference(),
            showID: showID,
            createdAt: createdAt,
            updatedAt: updatedAt,
        )
    }
}

private extension ShowRecord {
    func showMetadata(
        hostIndex: [String: HostRecord],
        publication: SchedulePublicationRecord,
    ) -> ShowMetadata {
        let hostNames = hostIDs.compactMap { hostIndex[$0]?.displayName }
        let showSegments = publication.segments.filter { $0.showID == id }
        let startsAt = showSegments.map(\.startsAt).min() ?? publication.validFrom
        let endsAt = showSegments
            .map { $0.startsAt.addingTimeInterval(TimeInterval($0.durationSeconds)) }
            .max() ?? startsAt.addingTimeInterval(TimeInterval(defaultDurationSeconds))

        return ShowMetadata(
            id: id,
            title: title,
            host: hostNames.joined(separator: ", "),
            summary: summary,
            artworkURL: artworkURL,
            startsAt: startsAt,
            endsAt: endsAt,
        )
    }
}
