import Vapor
import Authentication

final class ApiController {

    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)

        // create new token for this user
        let token = try UserToken.create(userID: user.requireID())

        // save and return token
        return token.save(on: req)
    }

    func updateFile(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)

        return try req.content.decode(UpdateFileTagRequest.self).flatMap { updateFileTagRequest in
            return try DownloadFile.find(updateFileTagRequest.id, on: req).and(result: updateFileTagRequest)
        }.flatMap { downloadFile, updateFileTagRequest throws -> Future<DownloadFile> in
            guard var file = downloadFile else {
                throw Abort(.internalServerError, reason: "Failed to load file data")
            }
            file.fileTag = updateFileTagRequest.tag
            return file.update(on: req)
        }.map { _ in
            return .ok
        }
    }

    func getFiles(_ req: Request) throws -> Future<[DownloadFile]> {
        let user = try req.requireAuthenticated(User.self)

        return DownloadFile.query(on: req).all()
    }
}