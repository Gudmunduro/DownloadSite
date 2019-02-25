import Vapor
import FluentMySQL

final class DownlaodSiteController {

    func index(_ req: Request) throws -> Future<View>
    {
        return try req.view().render("index")
    }

    func download(_ req: Request) throws -> Future<Response>
    {
        let fileTag = try req.parameters.next(String.self)
        let dbData = DownloadFile.query(on: req).filter(\.fileTag == fileTag).first()
        dbData.catch { (error) throws -> () in
            print(error)
            throw Abort(.badRequest, reason: "File does not exist")
        }
        return dbData.map { fileData -> Response in
            guard fileData != nil else {
                print("Filedata is nil")
                throw Abort(.badRequest, reason: "File does not exist")
            }
            guard let data = try? Data(contentsOf: fileStoragePath(filename: fileData!.fileTag)) else {
                print("Failed to load data")
                throw Abort(.internalServerError, reason: "Failed to load data")
            }
            print("File exists")
            let file = File(data: data, filename: fileData!.filename)
            return req.response(file: file)
        }
    }

}
