extension Result {

    func invoke(_ success: ((Success) -> Void)?, or failure: ((Failure) -> Void)?) {
        switch self {
        case let.success(result):
            success?(result)
        case let .failure(error):
            failure?(error)
        }
    }

}
