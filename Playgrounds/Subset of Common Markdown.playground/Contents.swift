
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

let ws = .space <|> .tab
let lower = ("a"..."z")%
let upper = ("A"..."Z")%
let text = (lower <|> upper <|> ws <|> .digit).string

let restOfLine = { $0.joined() } <^> text.many <* .newLine
let texts = { $0.joined() } <^> (text <|> (""% <* .newLine)).some

let element = fix { (element: @escaping (StringParser<String>) -> StringParser<Node>) in
	{ prefix in
		let octothorpes = { $0.count } <^> ("#"% * (1..<7))
		let header = prefix *> (Node.header <^> (lift(pair) <*> octothorpes <*> (.space *> restOfLine)))
		let paragpraph = prefix *> (Node.paragraph <^> texts)
		let blockquote = prefix *> delay{ Node.blockquote <^> some(element(prefix *> "> "%)) }
		
		return header <|> paragpraph <|> blockquote
	}
}(.pure(""))

do {
	let parsed = try element.parse("> # hello\n> \n> hello\n> there\n> \n> \n")
	print("1) " + parsed.description)
} catch (let err) {
	print(err)
}

do {
	let parsed = try element.parse("This is a \nparagraph\n")
	print("2) " + parsed.description)
} catch (let err) {
	print(err)
}

