import Hummingbird

func makeApplication(catalog: RadioCatalog = .unconfigured) -> Application<RouterResponder<BasicRequestContext>> {
    Application(
        router: makeRouter(catalog: catalog),
        configuration: .init(address: .hostname("127.0.0.1", port: 8080)),
    )
}

func makeRouter(catalog: RadioCatalog = .unconfigured) -> Router<BasicRequestContext> {
    let router = Router()

    router.get { _, _ -> String in
        "DjSwiftServer is running."
    }

    router.get("health") { _, _ -> HTTPResponse.Status in
        .ok
    }

    registerPublicRoutes(on: router, catalog: catalog)

    return router
}
