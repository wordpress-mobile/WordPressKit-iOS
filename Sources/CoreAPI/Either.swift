// Note that this is duplicated with the main WordPressKit but only for use when built as a Swift package.
//
// We could use a third-party shared implementation, but given it's so simple to implement copy-paste will do for the moment.
#if SWIFT_PACKAGE
enum Either<L, R> {
    case left(L)
    case right(R)

    func map<T>(left: (L) -> T, right: (R) -> T) -> T {
        switch self {
        case let .left(value):
            return left(value)
        case let .right(value):
            return right(value)
        }
    }
}
#endif
