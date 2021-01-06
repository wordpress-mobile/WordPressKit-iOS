import Foundation

public class JetpackRestoreTypes: NSObject {
    public let themes: Bool
    public let plugins: Bool
    public let uploads: Bool
    public let sqls: Bool
    public let roots: Bool
    public let contents: Bool

    init(themes: Bool, plugins: Bool, uploads: Bool, sqls: Bool, roots: Bool, contents: Bool) {
        self.themes = themes
        self.plugins = plugins
        self.uploads = uploads
        self.sqls = sqls
        self.roots = roots
        self.contents = contents
    }
    
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
