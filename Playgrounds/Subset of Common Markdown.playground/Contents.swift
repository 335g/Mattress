
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
