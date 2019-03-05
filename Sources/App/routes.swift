import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest())) // With basic (passwrod) auth header
    let bearer = router.grouped(User.tokenAuthMiddleware()) // With bearer auth header

    let downlaodSiteController = DownlaodSiteController()
    router.get(use: downlaodSiteController.index)
    router.get(String.parameter, use: downlaodSiteController.download)

    let apiController = ApiController()
    basic.post("api", "login", use: apiController.login)
    bearer.get("api", "update", use: apiController.updateFile)
    bearer.get("api", "files", use: apiController.getFiles)
}
