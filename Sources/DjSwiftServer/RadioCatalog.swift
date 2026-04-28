import Foundation

struct RadioCatalog {
    var health: @Sendable () -> HealthResponse
    var manifest: @Sendable () -> StationManifest
    var currentSchedule: @Sendable () -> ScheduleResponse
    var schedule: @Sendable (_ window: ScheduleWindow) -> ScheduleResponse
    var show: @Sendable (_ id: String) -> ShowMetadata?
    var voiceBreak: @Sendable (_ id: String) -> VoiceBreakDetail?
}

extension RadioCatalog {
    static var sample: Self {
        do {
            return try bundled()
        } catch {
            preconditionFailure("DjSwiftServer could not load the bundled authored catalog: \(error)")
        }
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
