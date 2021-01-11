import Foundation

public struct JetpackRestoreTypes: Decodable {
    public let themes: Bool
    public let plugins: Bool
    public let uploads: Bool
    public let sqls: Bool
    public let roots: Bool
    public let contents: Bool
    
    func toDictionary() -> [String: AnyObject] {
        return [
            "themes": themes as AnyObject,
            "plugins": plugins as AnyObject,
            "uploads": uploads as AnyObject,
            "sqls": sqls as AnyObject,
            "roots": roots as AnyObject,
            "contents": contents as AnyObject
        ]
    }
}
