import Hummingbird

@main
struct DjSwiftServerApp {
    static func main() async throws {
        let app = Application(
            router: makeRouter(),
            configuration: .init(address: .hostname("127.0.0.1", port: 8080))
        )

        try await app.runService()
    }
}

func makeRouter() -> Router<BasicRequestContext> {
    let router = Router()

    router.get { _, _ -> String in
        "DjSwiftServer is running."
    }

    router.get("health") { _, _ -> HTTPResponse.Status in
        .ok
    }

    return router
}
