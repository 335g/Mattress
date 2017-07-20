
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
					return str == elem
						? try ifSuccess(str, to)
						: try ifFailure(ParsingError(at: index, becauseOf: "\(elem) is not equal to \(str)"))
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
	
	public static var tabC: StringParser<Character> 		{ return .char("\t") }
	public static var spaceC: StringParser<Character> 		{ return .char(" ") }
	public static var commaC: StringParser<Character> 		{ return .char(",") }
	public static var dotC: StringParser<Character> 		{ return .char(".") }
	public static var newLineC: StringParser<Character> 	{ return .char("\n") }
	public static var crC: StringParser<Character> 			{ return .char("\r") }
	public static var crlfC: StringParser<Character> 		{ return .char("\r\n") }
	public static var endOfLineC: StringParser<Character> 	{ return .newLineC <|> .crlfC }
	public static var lparenC: StringParser<Character> 		{ return .char("(") }
	public static var rparenC: StringParser<Character> 		{ return .char(")") }
	public static var lbracketC: StringParser<Character> 	{ return .char("[") }
	public static var rbracketC: StringParser<Character> 	{ return .char("]") }
	public static var langleC: StringParser<Character> 		{ return .char("<") }
	public static var rangleC: StringParser<Character> 		{ return .char(">") }
	public static var lbraceC: StringParser<Character> 		{ return .char("{") }
	public static var rbraceC: StringParser<Character> 		{ return .char("}") }
	public static var semiC: StringParser<Character> 		{ return .char(";") }
	public static var colonC: StringParser<Character> 		{ return .char(":") }
	public static var squoteC: StringParser<Character> 		{ return .char("'") }
	public static var dquoteC: StringParser<Character>		{ return .char("\"") }
	public static var backslashC: StringParser<Character>	{ return .char("\\") }
	public static var equalsC: StringParser<Character> 		{ return .char("=") }
}
