/// Function returning an iterator for an empty sequence of T
public func emptyIterator<T>() -> AnyIterator<T> {
    return AnyIterator { nil }
}

/// Function returning an empty sequence of T
public func emptySequence<T>() -> AnySequence<T> {
    return AnySequence(EmptyCollection.Iterator())
}
