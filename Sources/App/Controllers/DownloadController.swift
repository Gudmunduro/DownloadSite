import Vapor
import FluentMySQL
import Crypto

final class DownlaodSiteController {

    func index(_ req: Request) throws -> Future<View>
    {
        return try req.view().render("index")
    }

    func manager(_ req: Request) throws -> Future<View>
    {
        return try req.view().render("manager")
    }

    func download(_ req: Request) throws -> Future<Response>
    {
        let fileTag = try req.parameters.next(String.self)
        return DownloadFile.query(on: req).filter(\.fileTag == fileTag).first().map { fileData in
            guard fileData != nil else {
                throw Abort(.badRequest, reason: "File does not exist")
            }
            guard let data = try? Data(contentsOf: fileStoragePath(filename: fileData!.fileTag)) else {
                throw Abort(.internalServerError, reason: "Failed to load data")
            }
            let file = File(data: data, filename: fileData!.filename)
            return req.response(file: file)
        }
    }

    func hashString(_ req: Request) throws -> String
    {
        let pass = try req.parameters.next(String.self)
        return try BCrypt.hash(pass, cost: 5)
    }

}
