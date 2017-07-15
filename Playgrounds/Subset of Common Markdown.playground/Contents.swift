
import Runes
import Mattress

indirect enum Node: CustomStringConvertible {
	case blockquote([Node])
	case header(Int, String)
	case paragraph(String)
	
	func analysis<T>(ifBlockquote: ([Node]) -> T, ifHeader: (Int, String) -> T, ifParagraph: (String) -> T) -> T {
		switch self {
		case .blockquote(let nodes):
			return ifBlockquote(nodes)
		case .header(let level, let text):
			return ifHeader(level, text)
		case .paragraph(let text):
			return ifParagraph(text)
		}
	}
	
	var description: String {
		return analysis(
			ifBlockquote: { "<blockquote>" + $0.lazy.map{ $0.description }.joined(separator: "") + "</blockquote>" },
			ifHeader: { "<h\($0)>\($1)</h\($0)>" },
			ifParagraph: { "<p>\($0)</p>" }
		)
	}
}

typealias NodeParser<T> = Parser<String.CharacterView, T, AnyObject>

func fix<T>(_ f: @escaping (@escaping () -> T) -> () -> T) -> () -> T {
	return { f(fix(f))() }
}

func pair<T, U>(_ t: T, _ u: U) -> (T, U) {
	return (t, u)
}

let ws: NodeParser<String> = { String($0) } <^> (.space <|> .tab)
let lower: NodeParser<String> = { String($0) } <^> %("a"..."z")
let upper: NodeParser<String> = { String($0) } <^> %("A"..."Z")
let digit: NodeParser<String> = { String($0) } <^> .digit
let text = lower <|> upper <|> digit <|> ws
let restOfLine = { $0.joined() } <^> text.many <* .newLine

try? digit.parse("10".characters)

//let nodeParser: NodeParser<Node> = fix { node in
//	{
//		let symbol: NodeParser<String> = { String($0) } <^> %("a"..."z")
//		let header: NodeParser<Node> = Node.header <^> symbol
//
//		return header
//	}
//}()



