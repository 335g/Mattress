
import Runes
import Mattress

//indirect enum Node: CustomStringConvertible {
//	case blockquote([Node])
//	case header(Int, String)
//	case paragraph(String)
//	
//	func analysis<T>(ifBlockquote: ([Node]) -> T, ifHeader: (Int, String) -> T, ifParagraph: (String) -> T) -> T {
//		switch self {
//		case .blockquote(let nodes):
//			return ifBlockquote(nodes)
//		case .header(let level, let text):
//			return ifHeader(level, text)
//		case .paragraph(let text):
//			return ifParagraph(text)
//		}
//	}
//	
//	var description: String {
//		return analysis(
//			ifBlockquote: { "<blockquote>" + $0.lazy.map{ $0.description }.joined(separator: "") + "</blockquote>" },
//			ifHeader: { "<h\($0)>\($1)</h\($0)>" },
//			ifParagraph: { "<p>\($0)</p>" }
//		)
//	}
//}

//typealias NodeParser<T> = Parser<String.CharacterView, T, Node>
//
//func fix<T>(_ f: @escaping (@escaping () -> T) -> () -> T) -> () -> T {
//	return { f(fix(f))() }
//}
//
//func pair<T, U>(_ t: T, _ u: U) -> (T, U) {
//	return (t, u)
//}

//let parser: NodeParser<Node> = fix { (element: @escaping (NodeParser<String>) -> NodeParser<Node>) in
//	{ prefix in
//		let octothorpes: NodeParser<Int> = { $0.count } <^> (%"#" * (1..<7))
//		let header = prefix *> (Node.header <^> (lift(pair) <*> octothorpes <*> ))
//		
//	}
//}

