// Note that this is duplicated between some targets.
//
// We could use a third-party shared implementation, but given it's so simple to implement copy-paste will do for the moment.
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