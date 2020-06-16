import XCTest
import WordPressKit

class PluginStateTests: XCTestCase {
    
    var decoder: JSONDecoder!
    var remote: PluginServiceRemote!
    
    override func setUp() {
        super.setUp()
        
        decoder = JSONDecoder()
        remote = PluginServiceRemote()
    }
    
    override func tearDown() {
        super.tearDown()
        
        decoder = nil
        remote = nil
    }

}
