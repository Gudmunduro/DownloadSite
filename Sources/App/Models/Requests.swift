import Vapor

struct UpdateFileTagRequest: Content {
    var id: Int
    var tag: String
}

struct UploadFileRequest: Content {
    var file: File
    var fileTag: String
}