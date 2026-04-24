@testable import DjSwiftServer
import Hummingbird
import HummingbirdTesting
import Testing

@Test func rootRouteReturnsStartupMessage() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/", method: .get) { response in
            #expect(response.status == .ok)
            #expect(String(buffer: response.body) == "DjSwiftServer is running.")
        }
    }
}

@Test func healthRouteReturnsOK() async throws {
    let app = Application(responder: makeRouter().buildResponder())

    try await app.test(.router) { client in
        try await client.execute(uri: "/health", method: .get) { response in
            #expect(response.status == .ok)
        }
    }
}
