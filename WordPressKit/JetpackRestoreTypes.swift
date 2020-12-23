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
            "themes": self.themes as AnyObject,
            "plugins": self.plugins as AnyObject,
            "uploads": self.uploads as AnyObject,
            "sqls": self.sqls as AnyObject,
            "roots": self.roots as AnyObject,
            "contents": self.contents as AnyObject
        ]
    }
}
