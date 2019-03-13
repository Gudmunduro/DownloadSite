import FluentMySQL
import Vapor

final class DownloadFile: MySQLModel {
    var id: Int?

    var fileTag: String

    var filename: String

    init(id: Int? = nil, fileTag: String, filename: String) {
        self.id = id
        self.fileTag = fileTag
        self.filename = filename
    }


}

extension DownloadFile: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(DownloadFile.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.fileTag)
            builder.field(for: \.filename)
            builder.unique(on: \.fileTag)
        }
    }
}

extension DownloadFile: Content { }

extension DownloadFile: Parameter { }
