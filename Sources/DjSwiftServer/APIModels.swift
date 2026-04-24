import Foundation
import Hummingbird

struct HealthResponse: ResponseCodable, Equatable {
    var status: String
    var serverTime: Date
    var apiVersion: String
}

struct StationManifest: ResponseCodable, Equatable {
    var apiVersion: String
    var station: StationIdentity
    var serverTime: Date
    var schedule: ScheduleReference
    var playback: PlaybackGuidance
    var supportedProviders: [ProviderKind]
    var links: ManifestLinks
}

struct StationIdentity: Codable, Equatable {
    var id: String
    var name: String
    var tagline: String
    var artworkURL: String
}

struct ScheduleReference: Codable, Equatable {
    var currentURL: String
    var validFrom: Date
    var validUntil: Date
    var revision: String
    var pollIntervalSeconds: Int
}

struct PlaybackGuidance: Codable, Equatable {
    var scheduleLookaheadSeconds: Int
    var prefetchBreakCount: Int
    var clockDriftToleranceSeconds: Int
    var clientPollIntervalSeconds: Int
}

struct ManifestLinks: Codable, Equatable {
    var scheduleCurrent: String
    var scheduleWindow: String
    var health: String
}

struct ScheduleResponse: ResponseCodable, Equatable {
    var id: String
    var revision: String
    var generatedAt: Date
    var validFrom: Date
    var validUntil: Date
    var serverTime: Date
    var segments: [ScheduleSegment]
}

struct ScheduleSegment: Codable, Equatable {
    var id: String
    var sequence: Int
    var kind: SegmentKind
    var startsAt: Date
    var durationSeconds: Int
    var driftPolicy: DriftPolicy
    var showID: String
    var track: TrackSegment?
    var voiceBreak: VoiceBreakReference?
}

enum SegmentKind: String, Codable, Equatable {
    case track
    case voiceBreak
    case showIntro
    case showOutro
}

enum DriftPolicy: String, Codable, Equatable {
    case anchorToWallClock
    case preserveRelativeOffset
    case skipIfLate
}

struct TrackSegment: Codable, Equatable {
    var title: String
    var artistName: String
    var albumTitle: String
    var durationSeconds: Int
    var isExplicit: Bool
    var providerReferences: [ProviderResolution]
}

struct ProviderResolution: Codable, Equatable {
    var provider: ProviderKind
    var catalogID: String?
    var storefront: String?
    var isrc: String?
    var uri: String?
    var availability: ProviderAvailability
}

enum ProviderKind: String, Codable, Equatable {
    case appleMusic
    case spotify
}

enum ProviderAvailability: String, Codable, Equatable {
    case resolved
    case needsStorefrontResolution
    case unavailable
}

struct VoiceBreakReference: Codable, Equatable {
    var id: String
    var title: String
    var audioURL: String
    var mimeType: String
    var durationSeconds: Int
    var checksum: String
    var loudnessLUFS: Double
    var transcript: String
    var provenance: VoiceBreakProvenance
}

enum VoiceBreakProvenance: String, Codable, Equatable {
    case recorded
    case aiGenerated
}

struct VoiceBreakDetail: ResponseCodable, Equatable {
    var breakInfo: VoiceBreakReference
    var showID: String
    var createdAt: Date
    var updatedAt: Date
}

struct ShowMetadata: ResponseCodable, Equatable {
    var id: String
    var title: String
    var host: String
    var summary: String
    var artworkURL: String
    var startsAt: Date
    var endsAt: Date
}
