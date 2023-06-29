import wpxmlrpc

struct XMLRPCFault: Error, LocalizedError{
    let code: Int
    let message: String

    var errorDescription: String? {
        self.message
    }
}

protocol ResponseProcessor {
    var decoder: WPXMLRPCDecoder? { get }
}

extension WPXMLRPCDecoder {
    func checkResponse() throws {
        guard self.isFault() else {
            return
        }

        let code = self.faultCode()
        guard let message = self.faultString() else {
            throw CocoaError(.coderReadCorrupt)
        }

        throw XMLRPCFault(code: code, message: message)
    }
}
