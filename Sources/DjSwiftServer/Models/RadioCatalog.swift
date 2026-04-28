import Foundation
import Hummingbird

struct RadioCatalog {
    var health: @Sendable () throws -> HealthResponse
    var manifest: @Sendable () throws -> StationManifest
    var currentSchedule: @Sendable () throws -> ScheduleResponse
    var schedule: @Sendable (_ window: ScheduleWindow) throws -> ScheduleResponse
    var show: @Sendable (_ id: String) throws -> ShowMetadata?
    var voiceBreak: @Sendable (_ id: String) throws -> VoiceBreakDetail?
}

extension RadioCatalog {
    static let unconfigured = Self(
        health: {
            throw catalogUnavailableError()
        },
        manifest: {
            throw catalogUnavailableError()
        },
        currentSchedule: {
            throw catalogUnavailableError()
        },
        schedule: { _ in
            throw catalogUnavailableError()
        },
        show: { _ in
            throw catalogUnavailableError()
        },
        voiceBreak: { _ in
            throw catalogUnavailableError()
        },
    )

    private static func catalogUnavailableError() -> HTTPError {
        HTTPError(
            .serviceUnavailable,
            message: "DjSwiftServer has no runtime catalog data source configured. Configure database-backed catalog storage before serving listener catalog routes.",
        )
    }
}

struct ScheduleWindow: Equatable {
    var from: Date
    var to: Date
}

extension ScheduleResponse {
    func filtered(to window: ScheduleWindow) -> Self {
        var response = self
        response.validFrom = window.from
        response.validUntil = window.to
        response.segments = segments.filter { segment in
            segment.startsAt < window.to && segment.endsAt > window.from
        }
        return response
    }
}

private extension ScheduleSegment {
    var endsAt: Date {
        startsAt.addingTimeInterval(TimeInterval(durationSeconds))
    }
}
