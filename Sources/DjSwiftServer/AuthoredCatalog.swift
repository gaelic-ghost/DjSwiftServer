import Foundation

struct AuthoredCatalog: Codable, Equatable {
    var station: StationRecord
    var hosts: [HostRecord]
    var shows: [ShowRecord]
    var tracks: [TrackRecord]
    var voiceBreaks: [VoiceBreakRecord]
    var publications: [SchedulePublicationRecord]
    var currentPublicationID: String
}

struct StationRecord: Codable, Equatable {
    var id: String
    var name: String
    var tagline: String
    var artworkURL: String
    var defaultTimezone: String
    var supportedProviders: [ProviderKind]
    var playbackPolicy: PlaybackPolicyRecord
    var links: ManifestLinks
}

struct PlaybackPolicyRecord: Codable, Equatable {
    var scheduleLookaheadSeconds: Int
    var prefetchBreakCount: Int
    var clockDriftToleranceSeconds: Int
    var clientPollIntervalSeconds: Int
}

struct HostRecord: Codable, Equatable {
    var id: String
    var displayName: String
    var summary: String
    var avatarURL: String
    var links: [String]
}

struct ShowRecord: Codable, Equatable {
    var id: String
    var title: String
    var hostIDs: [String]
    var summary: String
    var artworkURL: String
    var defaultDurationSeconds: Int
    var tags: [String]
}

struct TrackRecord: Codable, Equatable {
    var id: String
    var title: String
    var artistName: String
    var albumTitle: String
    var durationSeconds: Int
    var isExplicit: Bool
    var isrc: String?
    var providerReferences: [ProviderReferenceRecord]
    var metadataSource: String
    var updatedAt: Date
}

struct ProviderReferenceRecord: Codable, Equatable {
    var provider: ProviderKind
    var catalogID: String?
    var storefront: String?
    var isrc: String?
    var uri: String?
    var availability: ProviderAvailability
    var lastResolvedAt: Date?
    var resolutionSource: String?
}

struct VoiceBreakRecord: Codable, Equatable {
    var id: String
    var title: String
    var audioURL: String
    var mimeType: String
    var durationSeconds: Int
    var checksum: String
    var loudnessLUFS: Double
    var transcript: String
    var provenance: VoiceBreakProvenance
    var showID: String
    var createdAt: Date
    var updatedAt: Date
}

struct SchedulePublicationRecord: Codable, Equatable {
    var id: String
    var revision: String
    var generatedAt: Date
    var validFrom: Date
    var validUntil: Date
    var segments: [ScheduleSegmentRecord]
    var source: String
}

struct ScheduleSegmentRecord: Codable, Equatable {
    var id: String
    var sequence: Int
    var kind: SegmentKind
    var startsAt: Date
    var durationSeconds: Int
    var driftPolicy: DriftPolicy
    var showID: String
    var trackID: String?
    var voiceBreakID: String?
    var notes: String?
}

struct CatalogValidationIssue: Error, CustomStringConvertible, Equatable {
    var recordType: String
    var recordID: String
    var field: String
    var message: String
    var likelyFix: String

    var description: String {
        "\(recordType) '\(recordID)' field '\(field)' is invalid: \(message) Likely fix: \(likelyFix)"
    }
}

struct CatalogValidationError: Error, CustomStringConvertible, Equatable {
    var issues: [CatalogValidationIssue]

    var description: String {
        let issueList = issues.map(\.description).joined(separator: " ")
        return "DjSwiftServer authored catalog validation failed with \(issues.count) issue(s). \(issueList)"
    }
}

enum AuthoredCatalogLoader {
    static let bundledResourceName = "catalog"
    static let bundledResourceExtension = "json"

    static func loadBundledCatalog() throws -> AuthoredCatalog {
        guard let url = Bundle.module.url(
            forResource: bundledResourceName,
            withExtension: bundledResourceExtension,
        ) else {
            throw CatalogValidationIssue(
                recordType: "Bundle",
                recordID: "DjSwiftServer",
                field: "Resources/catalog.json",
                message: "The bundled authored catalog resource was not found.",
                likelyFix: "Declare the Resources directory in Package.swift and include catalog.json under Sources/DjSwiftServer/Resources.",
            )
        }

        let data = try Data(contentsOf: url)
        return try load(data: data)
    }

    static func load(data: Data) throws -> AuthoredCatalog {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let catalog = try decoder.decode(AuthoredCatalog.self, from: data)
        try catalog.validate()
        return catalog
    }
}

extension AuthoredCatalog {
    func validate() throws {
        var issues: [CatalogValidationIssue] = []

        issues += duplicateIDIssues("HostRecord", records: hosts.map { ($0.id, "id") })
        issues += duplicateIDIssues("ShowRecord", records: shows.map { ($0.id, "id") })
        issues += duplicateIDIssues("TrackRecord", records: tracks.map { ($0.id, "id") })
        issues += duplicateIDIssues("VoiceBreakRecord", records: voiceBreaks.map { ($0.id, "id") })
        issues += duplicateIDIssues("SchedulePublication", records: publications.map { ($0.id, "id") })

        let hostIDs = Set(hosts.map(\.id))
        let showIDs = Set(shows.map(\.id))
        let trackIDs = Set(tracks.map(\.id))
        let voiceBreakIDs = Set(voiceBreaks.map(\.id))
        let publicationIDs = Set(publications.map(\.id))

        if !publicationIDs.contains(currentPublicationID) {
            issues.append(issue(
                "AuthoredCatalog",
                currentPublicationID,
                "currentPublicationID",
                "No publication exists with this ID.",
                "Set currentPublicationID to an ID from publications.",
            ))
        }

        issues += validatePublicURL(station.artworkURL, "StationRecord", station.id, "artworkURL")

        for host in hosts {
            if !host.avatarURL.isEmpty {
                issues += validatePublicURL(host.avatarURL, "HostRecord", host.id, "avatarURL")
            }
        }

        for show in shows {
            for hostID in show.hostIDs where !hostIDs.contains(hostID) {
                issues.append(issue(
                    "ShowRecord",
                    show.id,
                    "hostIDs",
                    "Host ID '\(hostID)' does not exist.",
                    "Add the host record or remove the missing host ID from this show.",
                ))
            }

            if show.defaultDurationSeconds <= 0 {
                issues.append(issue(
                    "ShowRecord",
                    show.id,
                    "defaultDurationSeconds",
                    "Show duration must be greater than zero seconds.",
                    "Use a positive duration for the show definition.",
                ))
            }

            issues += validatePublicURL(show.artworkURL, "ShowRecord", show.id, "artworkURL")
        }

        for track in tracks {
            if track.durationSeconds <= 0 {
                issues.append(issue(
                    "TrackRecord",
                    track.id,
                    "durationSeconds",
                    "Track duration must be greater than zero seconds.",
                    "Use the provider or authored track duration in seconds.",
                ))
            }

            for reference in track.providerReferences {
                issues += validateProviderReference(reference, trackID: track.id)
            }
        }

        for voiceBreak in voiceBreaks {
            if !showIDs.contains(voiceBreak.showID) {
                issues.append(issue(
                    "VoiceBreakRecord",
                    voiceBreak.id,
                    "showID",
                    "Show ID '\(voiceBreak.showID)' does not exist.",
                    "Add the show record or point this voice break at an existing show.",
                ))
            }

            if voiceBreak.durationSeconds <= 0 {
                issues.append(issue(
                    "VoiceBreakRecord",
                    voiceBreak.id,
                    "durationSeconds",
                    "Voice-break duration must be greater than zero seconds.",
                    "Use the measured voice-break duration in seconds.",
                ))
            }

            if !voiceBreak.checksum.contains(":") {
                issues.append(issue(
                    "VoiceBreakRecord",
                    voiceBreak.id,
                    "checksum",
                    "Checksum is missing an algorithm prefix.",
                    "Use a value like sha256:<digest>.",
                ))
            }

            issues += validatePublicURL(voiceBreak.audioURL, "VoiceBreakRecord", voiceBreak.id, "audioURL")
        }

        for publication in publications {
            issues += validatePublication(
                publication,
                showIDs: showIDs,
                trackIDs: trackIDs,
                voiceBreakIDs: voiceBreakIDs,
            )
        }

        guard issues.isEmpty else {
            throw CatalogValidationError(issues: issues)
        }
    }

    private func validatePublication(
        _ publication: SchedulePublicationRecord,
        showIDs: Set<String>,
        trackIDs: Set<String>,
        voiceBreakIDs: Set<String>,
    ) -> [CatalogValidationIssue] {
        var issues: [CatalogValidationIssue] = []

        if publication.validUntil <= publication.validFrom {
            issues.append(issue(
                "SchedulePublication",
                publication.id,
                "validUntil",
                "Publication validUntil must be later than validFrom.",
                "Use a validity window where validUntil is after validFrom.",
            ))
        }

        let sequences = publication.segments.map(\.sequence)
        if Set(sequences).count != sequences.count {
            issues.append(issue(
                "SchedulePublication",
                publication.id,
                "segments.sequence",
                "Segment sequence values must be unique within the publication.",
                "Give each segment a unique sequence number.",
            ))
        }

        if sequences != sequences.sorted() {
            issues.append(issue(
                "SchedulePublication",
                publication.id,
                "segments.sequence",
                "Segments must be sorted by sequence.",
                "Order publication segments by ascending sequence.",
            ))
        }

        for segment in publication.segments {
            if !showIDs.contains(segment.showID) {
                issues.append(issue(
                    "ScheduleSegmentRecord",
                    segment.id,
                    "showID",
                    "Show ID '\(segment.showID)' does not exist.",
                    "Add the show record or point this segment at an existing show.",
                ))
            }

            if segment.durationSeconds <= 0 {
                issues.append(issue(
                    "ScheduleSegmentRecord",
                    segment.id,
                    "durationSeconds",
                    "Segment duration must be greater than zero seconds.",
                    "Use a positive segment duration.",
                ))
            }

            switch segment.kind {
                case .track:
                    if let trackID = segment.trackID {
                        if !trackIDs.contains(trackID) {
                            issues.append(issue(
                                "ScheduleSegmentRecord",
                                segment.id,
                                "trackID",
                                "Track ID '\(trackID)' does not exist.",
                                "Add the track record or point this segment at an existing track.",
                            ))
                        }
                    } else {
                        issues.append(issue(
                            "ScheduleSegmentRecord",
                            segment.id,
                            "trackID",
                            "Track segments require a trackID.",
                            "Set trackID to an existing TrackRecord ID.",
                        ))
                    }
                case .voiceBreak, .showIntro, .showOutro:
                    if let voiceBreakID = segment.voiceBreakID {
                        if !voiceBreakIDs.contains(voiceBreakID) {
                            issues.append(issue(
                                "ScheduleSegmentRecord",
                                segment.id,
                                "voiceBreakID",
                                "Voice break ID '\(voiceBreakID)' does not exist.",
                                "Add the voice break record or point this segment at an existing voice break.",
                            ))
                        }
                    } else {
                        issues.append(issue(
                            "ScheduleSegmentRecord",
                            segment.id,
                            "voiceBreakID",
                            "Voice-break-backed segments require a voiceBreakID.",
                            "Set voiceBreakID to an existing VoiceBreakRecord ID.",
                        ))
                    }
            }
        }

        return issues
    }

    private func validateProviderReference(
        _ reference: ProviderReferenceRecord,
        trackID: String,
    ) -> [CatalogValidationIssue] {
        var issues: [CatalogValidationIssue] = []
        let recordID = "\(trackID):\(reference.provider.rawValue)"

        if reference.provider == .appleMusic, reference.catalogID != nil, reference.storefront == nil {
            issues.append(issue(
                "ProviderReferenceRecord",
                recordID,
                "storefront",
                "Apple Music catalogID references must include the storefront where that ID is valid.",
                "Set storefront to an ISO 3166 alpha-2 storefront such as us.",
            ))
        }

        switch reference.availability {
            case .resolved:
                let hasDirectReference = reference.catalogID != nil || reference.uri != nil
                if !hasDirectReference {
                    issues.append(issue(
                        "ProviderReferenceRecord",
                        recordID,
                        "availability",
                        "Resolved provider references need a catalogID or uri.",
                        "Set catalogID, uri, or lower availability to needsStorefrontResolution.",
                    ))
                }
            case .needsStorefrontResolution:
                if reference.isrc == nil, reference.uri == nil {
                    issues.append(issue(
                        "ProviderReferenceRecord",
                        recordID,
                        "isrc",
                        "Storefront-resolution references need ISRC or a provider URI fallback.",
                        "Set isrc, uri, or mark the provider reference unavailable.",
                    ))
                }
            case .unavailable:
                break
        }

        return issues
    }

    private func duplicateIDIssues(
        _ recordType: String,
        records: [(id: String, field: String)],
    ) -> [CatalogValidationIssue] {
        var seen: Set<String> = []
        var duplicates: [CatalogValidationIssue] = []

        for record in records {
            if !seen.insert(record.id).inserted {
                duplicates.append(issue(
                    recordType,
                    record.id,
                    record.field,
                    "Duplicate ID '\(record.id)' appears more than once.",
                    "Give every \(recordType) a unique stable ID.",
                ))
            }
        }

        return duplicates
    }

    private func validatePublicURL(
        _ value: String,
        _ recordType: String,
        _ recordID: String,
        _ field: String,
    ) -> [CatalogValidationIssue] {
        guard let url = URL(string: value), url.scheme != nil, url.host != nil else {
            return [
                issue(
                    recordType,
                    recordID,
                    field,
                    "Expected an absolute public URL, but found '\(value)'.",
                    "Use an absolute https URL for public media and artwork fields.",
                ),
            ]
        }

        return []
    }

    private func issue(
        _ recordType: String,
        _ recordID: String,
        _ field: String,
        _ message: String,
        _ likelyFix: String,
    ) -> CatalogValidationIssue {
        CatalogValidationIssue(
            recordType: recordType,
            recordID: recordID,
            field: field,
            message: message,
            likelyFix: likelyFix,
        )
    }
}
