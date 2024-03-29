import clibxml2
import struct Foundation.Data

func fromContext<A: AnyObject>(_ type: A.Type, _ context: UnsafeMutableRawPointer) -> A {
    Unmanaged<A>.fromOpaque(context).takeUnretainedValue()
}

func fromContext<A: AnyObject>(_ type: A.Type, _ context: UnsafeMutableRawPointer?) -> A? {
    guard let context = context else { return nil }
    return Unmanaged<A>.fromOpaque(context).takeUnretainedValue()
}

internal extension String {
    
    init?(xml:UnsafePointer<xmlChar>) {
        var castedXML : UnsafePointer<Int8>? = nil
        xml.withMemoryRebound(to: Int8.self, capacity: 20) { input in
            castedXML = input
        }
        self.init(validatingUTF8:castedXML!)
    }
    
}

internal enum XMLNodeType : UInt8 {
    
    case element = 1 // XML_ELEMENT_NODE
    case attribute = 2 // XML_ATTRIBUTE_NODE
    case text = 3 // XML_TEXT_NODE
    case cdataSection = 4 // XML_CDATA_SECTION_NODE
    case entityReference = 5 // XML_ENTITY_REF_NODE
    case entity = 6 // XML_ENTITY_NODE
    case processingInstruction = 7 // XML_PI_NODE
    case comment = 8 // XML_COMMENT_NODE
    case document = 9 // XML_DOCUMENT_NODE
    case documentType = 10 // XML_DOCUMENT_TYPE_NODE
    case documentFragment = 11 // XML_DOCUMENT_FRAG_NODE
    case notation = 12 // XML_NOTATION_NODE
    case htmlDocument = 13 // XML_HTML_DOCUMENT_NODE
    case dtd = 14 // XML_DTD_NODE
    case elementDeclaration = 15 // XML_ELEMENT_DECL
    case attributeDeclaration = 16 // XML_ATTRIBUTE_DECL
    case entityDeclaration = 17 // XML_ENTITY_DECL
    case namespaceDeclaration = 18 // XML_NAMESPACE_DECL
    case xIncludeStart = 19 // XML_XINCLUDE_START
    case xIncludeEnd = 20 // XML_XINCLUDE_END
    
}

internal var XMLParserErrorHandler : xmlTextReaderErrorFunc = { (arg, messageIn, severity, locator) in
    var reader : XMLReader? = nil
    
    if let arg = arg {
        // Note that we take the value "unretained", otherwise we consume it as retained, so we release it, but causes us to free our reader.
        reader = Unmanaged<XMLReader>.fromOpaque(arg).takeUnretainedValue()
    }
    
    let message : String?
    if let messageIn = messageIn {
        message = String(validatingUTF8:messageIn)
    } else {
        message = ""
    }
    
    var baseURI : String? = nil
    if let rawBaseURI = xmlTextReaderLocatorBaseURI(locator) {
        baseURI = String(xml: rawBaseURI)
    }
    let lineNumber = xmlTextReaderLocatorLineNumber(locator)
    let formattedMessage = "\(baseURI ?? "UNKNOWN"):\(lineNumber): \(message!)"
    
    if severity == XML_PARSER_SEVERITY_ERROR {
        reader?.parser(reader:locator!, parseErrorOccurred: message!)
    } else {
        print("warning", message ?? "nil")
    }
}

internal class XMLReader {
    var reader: xmlTextReaderPtr?
    var unsafeBytes: UnsafeMutablePointer<Int8>? // A pointer to the data passed to us.
    
    internal init?(data: Data, url: String? = nil, encoding: String? = "utf8", options: Int = 0) {
        let count = data.count
        unsafeBytes = UnsafeMutablePointer<Int8>.allocate(capacity: data.count)
        unsafeBytes?.withMemoryRebound(to: UInt8.self, capacity: count) { retypedData in
            data.copyBytes(to: retypedData, count: count)
        }
        self.reader = xmlReaderForMemory(unsafeBytes, Int32(count), url, encoding, Int32(options | Int(XML_PARSE_RECOVER.rawValue)))
        //print("\(xmlTextReaderGetParserProp(reader, Int32(XML_PARSER_SUBST_ENTITIES.rawValue)))")
        if let reader = reader {
            xmlTextReaderSetErrorHandler(reader, XMLParserErrorHandler, Unmanaged.passRetained(self).toOpaque())
        } else {
            return nil
        }
    }
    
    deinit {
        unsafeBytes?.deallocate()
    }
    
    func read() -> Bool {
        let result = xmlTextReaderRead(reader)
        //        if result < 0 {
        //            print("hard failure: \(result)")
        //        }
        return result == 1
    }
    
    var nodeType : XMLNodeType {
        return XMLNodeType(rawValue:UInt8(xmlTextReaderNodeType(reader)))!
    }
    
    var name : String? {
        return String(xml: xmlTextReaderConstName(reader))
    }
    
    var hasValue : Bool {
        return xmlTextReaderHasValue(reader) != 0
    }
    
    var value : String? {
        return hasValue ? String(xml: xmlTextReaderConstValue(reader)!) : nil
    }
    
    var isEmptyElement : Bool {
        return xmlTextReaderIsEmptyElement(reader) != 0
    }
    
    func moveToNextAttribute() -> Bool {
        return xmlTextReaderMoveToNextAttribute(reader) == 1
    }
    
    var isStandalone : Bool {
        return xmlTextReaderStandalone(reader) != 0
    }
    
    var xmlVersion : String? {
        if let raw = xmlTextReaderConstXmlVersion(reader) {
            return String(xml: raw)
        }
        return nil
    }
    
    var encoding : String? {
        if let raw = xmlTextReaderConstEncoding(reader) {
            return String(xml: raw)
        }
        return nil
    }
    
    var currentNode : xmlNodePtr? {
        return xmlTextReaderCurrentNode(reader)
    }
    
    func close() -> Void {
        xmlTextReaderClose(reader)
    }
    
    func parser(reader: xmlTextReaderLocatorPtr, parseErrorOccurred error: String?) {
        print("error", error ?? "nil")
    }
    
}

let xml = """
<html>
<head>
  <title>Href Attribute Example</title>
</head>
<body>
  <h1>Href Attribute Example</h1>
  <p>
    <a href="https://www.freecodecamp.org/contribute/">The freeCodeCamp Contribution Page</a> shows you how and where you can contribute to freeCodeCamp's community and growth.
  </p>
</body>
</html>
"""

guard let data = xml.data(using: .utf8) else { fatalError() }
let reader = XMLReader(data: data)
_ = reader?.read()
print(reader?.nodeType ?? "nil")
print(reader?.xmlVersion ?? "nil")
