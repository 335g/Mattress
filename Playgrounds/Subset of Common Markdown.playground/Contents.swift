
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

func fix<T, U>(_ f: @escaping (@escaping (T) -> U) -> (T) -> U) -> (T) -> U {
	return { f(fix(f))($0) }
}

func pair<T, U>(_ t: T, _ u: U) -> (T, U) {
	return (t, u)
}

let ws: StringParser<String> = { String($0) } <^> (.space <|> .tab)
let lower: StringParser<String> = { String($0) } <^> %("a"..."z")
let upper: StringParser<String> = { String($0) } <^> %("A"..."Z")
let digit: StringParser<String> = { String($0) } <^> .digit
let text = lower <|> upper <|> digit <|> ws
let restOfLine = { $0.joined() } <^> text.many <* .newLine
let texts = { $0.joined() } <^> (text <|> (%"" <* .newLine)).some

let element = fix { (element: @escaping (StringParser<String>) -> StringParser<Node>) in
	{ prefix in
		let octothorpes = { $0.count } <^> (%"#" * (1..<7))
		let header = prefix *> (Node.header <^> (lift(pair) <*> octothorpes <*> (.space *> restOfLine)))
		let paragpraph = prefix *> (Node.paragraph <^> texts)
		let blockquote = prefix *> delay{ Node.blockquote <^> some(element(prefix *> %"> ")) }
		
		return header <|> paragpraph <|> blockquote
	}
}(.pure(""))

// > # hello\n> \n> hello\n> there\n> \n> \n
//do {
//	let parsed = try element.parse("#") as! Node
//	print(parsed.description)
//} catch(let e) {
//	print(e)
//}

