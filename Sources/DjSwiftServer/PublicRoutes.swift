import Foundation
import Hummingbird

func registerPublicRoutes(on router: Router<BasicRequestContext>, catalog: RadioCatalog) {
    router.get("/v1/health") { _, _ -> HealthResponse in
        try catalog.health()
    }

    router.get("/v1/manifest") { _, _ -> StationManifest in
        try catalog.manifest()
    }

    router.get("/v1/schedule/current") { _, _ -> ScheduleResponse in
        try catalog.currentSchedule()
    }

    router.get("/v1/schedule") { request, _ -> ScheduleResponse in
        let window = try ScheduleWindow(request: request)
        return try catalog.schedule(window)
    }

    router.get("/v1/shows/:showID") { _, context -> ShowMetadata in
        let showID = try context.parameters.require("showID")
        guard let show = try catalog.show(showID) else {
            throw HTTPError(.notFound, message: "No show metadata exists for show ID '\(showID)'.")
        }

        return show
    }

    router.get("/v1/breaks/:breakID") { _, context -> VoiceBreakDetail in
        let breakID = try context.parameters.require("breakID")
        guard let voiceBreak = try catalog.voiceBreak(breakID) else {
            throw HTTPError(.notFound, message: "No voice break metadata exists for break ID '\(breakID)'.")
        }

        return voiceBreak
    }
}

private extension ScheduleWindow {
    init(request: Request) throws {
        let from = try Self.requiredDate(named: "from", in: request)
        let to = try Self.requiredDate(named: "to", in: request)
        guard to > from else {
            throw HTTPError(
                .badRequest,
                message: "Schedule window query parameter 'to' must be later than 'from'.",
            )
        }

        self.init(from: from, to: to)
    }

    static func requiredDate(named name: String, in request: Request) throws -> Date {
        guard let value = request.uri.queryParameters[name[...]] else {
            throw HTTPError(
                .badRequest,
                message: "Schedule window requires ISO 8601 query parameter '\(name)'.",
            )
        }

        let dateString = String(value)
        guard dateString.hasSuffix("Z"), let date = ISO8601DateFormatter().date(from: dateString) else {
            throw HTTPError(
                .badRequest,
                message: "Schedule window query parameter '\(name)' must be an ISO 8601 UTC timestamp, such as 2026-04-24T16:00:00Z.",
            )
        }

        return date
    }
}
