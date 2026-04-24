import Hummingbird

func registerPublicRoutes(on router: Router<BasicRequestContext>, catalog: RadioCatalog) {
    router.get("/v1/health") { _, _ -> HealthResponse in
        catalog.health()
    }

    router.get("/v1/manifest") { _, _ -> StationManifest in
        catalog.manifest()
    }

    router.get("/v1/schedule/current") { _, _ -> ScheduleResponse in
        catalog.currentSchedule()
    }

    router.get("/v1/schedule") { _, _ -> ScheduleResponse in
        catalog.currentSchedule()
    }

    router.get("/v1/shows/:showID") { _, context -> ShowMetadata in
        let showID = try context.parameters.require("showID")
        guard let show = catalog.show(showID) else {
            throw HTTPError(.notFound, message: "No show metadata exists for show ID '\(showID)'.")
        }

        return show
    }

    router.get("/v1/breaks/:breakID") { _, context -> VoiceBreakDetail in
        let breakID = try context.parameters.require("breakID")
        guard let voiceBreak = catalog.voiceBreak(breakID) else {
            throw HTTPError(.notFound, message: "No voice break metadata exists for break ID '\(breakID)'.")
        }

        return voiceBreak
    }
}
