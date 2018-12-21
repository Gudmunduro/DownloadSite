import Vapor

extension Request {
    func response(file: File) -> Response {
        let headers: HTTPHeaders = [
            "content-disposition": "attachment; filename=\"\(file.filename)\""
        ]
        let res = HTTPResponse(headers: headers, body: file.data)
        return response(http: res)
    }
}