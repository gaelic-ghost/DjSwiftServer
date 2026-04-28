import Hummingbird

@main
struct DjSwiftServerApp {
    static func main() async throws {
        try await makeApplication().runService()
    }
}
