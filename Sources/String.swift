
import Runes

public typealias StringParser<T> = Parser<String.CharacterView, T>

extension Parser where C == String.CharacterView {
	public static func equal(to str: String) -> StringParser<String> {
		return Parser<String.CharacterView, String>{ input, index, ifFailure, ifSuccess in
			return index >= input.endIndex
				? try ifFailure(ParsingError(at: index, becauseOf: "\(index) is over endIndex."))
				: try {
					guard let to = input.index(index, offsetBy: str.count, limitedBy: input.endIndex) else {
						return try ifFailure(ParsingError(at: index, becauseOf: ""))
					}
					
					let elem = String(input[index..<to])
					return elem == str
						? try ifSuccess(elem, to)
						: try ifFailure(ParsingError(at: index, becauseOf: "\(elem) is not equal to \(to)"))
					}()
		}
	}
	
	public static var tab: StringParser<String> 		{ return .equal(to: "\t") }
	public static var space: StringParser<String> 		{ return .equal(to: " ") }
	public static var comma: StringParser<String> 		{ return .equal(to: ",") }
	public static var dot: StringParser<String> 		{ return .equal(to: ".") }
	public static var newLine: StringParser<String> 	{ return .equal(to: "\n") }
	public static var cr: StringParser<String> 			{ return .equal(to: "\r") }
	public static var crlf: StringParser<String> 		{ return .equal(to: "\r\n") }
	public static var endOfLine: StringParser<String> 	{ return .newLine <|> .crlf }
	public static var lparen: StringParser<String> 		{ return .equal(to: "(") }
	public static var rparen: StringParser<String> 		{ return .equal(to: ")") }
	public static var lbracket: StringParser<String> 	{ return .equal(to: "[") }
	public static var rbracket: StringParser<String> 	{ return .equal(to: "]") }
	public static var langle: StringParser<String> 		{ return .equal(to: "<") }
	public static var rangle: StringParser<String> 		{ return .equal(to: ">") }
	public static var lbrace: StringParser<String> 		{ return .equal(to: "{") }
	public static var rbrace: StringParser<String> 		{ return .equal(to: "}") }
	public static var semi: StringParser<String> 		{ return .equal(to: ";") }
	public static var colon: StringParser<String> 		{ return .equal(to: ":") }
	public static var squote: StringParser<String> 		{ return .equal(to: "'") }
	public static var dquote: StringParser<String>		{ return .equal(to: "\"") }
	public static var backslash: StringParser<String>	{ return .equal(to: "\\") }
	public static var equals: StringParser<String> 		{ return .equal(to: "=") }
	
	public static func oneOf(_ input: String) -> StringParser<Character> {
		return .satisfy{ input.characters.contains($0) }
	}
	
	public static func noneOf(_ input: String) -> StringParser<Character> {
		return .satisfy{ !input.characters.contains($0) }
	}
}

extension Parser where C == String.CharacterView, T == Character {
	public static func char(_ x: Character) -> StringParser<Character> {
		return .satisfy{ $0 == x }
	}
}
