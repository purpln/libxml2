import clibxml2

///
/// XML Name space representation
///
public struct XMLNameSpace {
    let ns: xmlNsPtr
}

extension XMLNameSpace {
    /// prefix of the XML namespace
    public var prefix: String? {
        let prefix: UnsafePointer<xmlChar>? = ns.pointee.prefix
        return prefix.map { String(cString: UnsafePointer($0)) }
    }

    /// href URI of the XML namespace
    public var href: String? {
        let href: UnsafePointer<xmlChar>? = ns.pointee.href
        return href.map { String(cString: UnsafePointer($0)) }
    }
}


//
// MARK: - Enumerating XML namespaces
//
extension XMLNameSpace: Sequence {
    public func makeIterator() -> XMLNameSpace.Iterator {
        return Iterator(root: self)
    }
}


extension XMLNameSpace {
    public class Iterator: IteratorProtocol {
        var current: XMLNameSpace?

        /// create a generator from a root element
        init(root: XMLNameSpace) {
            current = root
        }

        /// return the next element following a depth-first pre-order traversal
        public func next() -> XMLNameSpace? {
            let c = current
            let sibling = c?.ns.pointee.next
            current = sibling.map(XMLNameSpace.init)
            return c
        }
    }
}
