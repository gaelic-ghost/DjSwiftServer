@testable import DjSwiftServer
import Foundation
import Hummingbird
import HummingbirdTesting
import Testing

@Test func `root route returns startup message`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/", method: .get) { response in
            #expect(response.status == .ok)
            #expect(String(buffer: response.body) == "DjSwiftServer is running.")
        }
    }
}

@Test func `health route returns OK`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/health", method: .get) { response in
            #expect(response.status == .ok)
        }
    }
}

@Test func `public health route returns JSON contract`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/health", method: .get) { response in
            let health = try decode(HealthResponse.self, from: response)

            #expect(response.status == .ok)
            #expect(health.status == "ok")
            #expect(health.apiVersion == "v1")
        }
    }
}

@Test func `manifest route returns station and polling guidance`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/manifest", method: .get) { response in
            let manifest = try decode(StationManifest.self, from: response)

            #expect(response.status == .ok)
            #expect(manifest.apiVersion == "v1")
            #expect(manifest.station.id == "dj-radio")
            #expect(manifest.schedule.currentURL == "/v1/schedule/current")
            #expect(manifest.playback.prefetchBreakCount == 3)
            #expect(manifest.supportedProviders == [.appleMusic, .spotify])
        }
    }
}

@Test func `current schedule route returns ordered segments`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/schedule/current", method: .get) { response in
            let schedule = try decode(ScheduleResponse.self, from: response)

            #expect(response.status == .ok)
            #expect(schedule.revision == "2026-04-24T16:00:00Z-sample")
            #expect(schedule.segments.map(\.sequence) == [1, 2, 3])
            #expect(schedule.segments[0].kind == .showIntro)
            #expect(schedule.segments[1].track?.providerIDs.first?.provider == .appleMusic)
            #expect(schedule.segments[2].voiceBreak?.provenance == .aiGenerated)
        }
    }
}

@Test func `schedule window route currently returns current schedule placeholder`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/schedule?from=2026-04-24T16:00:00Z&to=2026-04-24T18:00:00Z", method: .get) { response in
            let schedule = try decode(ScheduleResponse.self, from: response)

            #expect(response.status == .ok)
            #expect(schedule.id == "schedule-2026-04-24-friday-signal")
        }
    }
}

@Test func `show route returns known show metadata`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/shows/show-friday-signal", method: .get) { response in
            let show = try decode(ShowMetadata.self, from: response)

            #expect(response.status == .ok)
            #expect(show.title == "Friday Signal")
            #expect(show.host == "Gale")
        }
    }
}

@Test func `voice break route returns known break metadata`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/breaks/break-friday-signal-intro", method: .get) { response in
            let voiceBreak = try decode(VoiceBreakDetail.self, from: response)

            #expect(response.status == .ok)
            #expect(voiceBreak.breakInfo.mimeType == "audio/mp4")
            #expect(voiceBreak.breakInfo.provenance == .recorded)
        }
    }
}

@Test func `unknown show returns not found`() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/v1/shows/missing-show", method: .get) { response in
            #expect(response.status == .notFound)
            #expect(String(buffer: response.body).contains("No show metadata exists for show ID 'missing-show'."))
        }
    }
}

private func decode<Value: Decodable>(_ type: Value.Type, from response: TestResponse) throws -> Value {
    let body = String(buffer: response.body)
    let data = try #require(body.data(using: .utf8))
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(type, from: data)
}
