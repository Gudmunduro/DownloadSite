import Vapor
import FluentMySQL

final class DownlaodSiteController {

    func download(_ req: Request) throws -> Future<Response>
    {
        let fileTag = try req.parameters.next(String.self)
        return DownloadFile.query(on: req).filter(\.fileTag == fileTag).first().map { fileData in
            guard fileData != nil else {
                throw Abort(.internalServerError, reason: "Invalid tag")
            }
            let file = File(data: try Data(contentsOf: fileStoragePath(filename: fileData!.fileTag)), filename: fileData!.filename)
            return req.response(file: file)
        }
    }

}
