import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest())) // With basic (passwrod) auth header
    let bearer = router.grouped(User.tokenAuthMiddleware()) // With bearer auth header

    let downlaodSiteController = DownlaodSiteController()
    router.get(use: downlaodSiteController.index)
    router.get(String.parameter, use: downlaodSiteController.download)
    router.get("manager", use: downlaodSiteController.manager)

    router.get("api", "hash", String.parameter, use: downlaodSiteController.hashString)

    let apiController = ApiController()
    basic.post("api", "login", use: apiController.login)
    bearer.post("api", "update", use: apiController.updateFile)
    bearer.post("api", "upload", use: apiController.uploadFile)
    bearer.get("api", "files", use: apiController.getFiles)
}
