import Vapor

func fileStoragePath(filename: String) -> URL 
{
    let workDir = DirectoryConfig.detect().workDir
    return URL(fileURLWithPath: workDir).appendingPathComponent("files", isDirectory: true).appendingPathComponent(filename, isDirectory: false)
}