import Foundation

public enum SomeNumberOf<T> {
    case zero
    case one(T)
    case many([T])
}
