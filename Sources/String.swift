
import Runes

public typealias StringParser<T> = Parser<String.CharacterView, T>

extension Parser where C == String.CharacterView {
	public static func char(_ x: Character) -> StringParser<Character> {
		return .satisfy{ $0 == x }
	}
	
	public static var tab: StringParser<Character> 			{ return .char("\t") }
	public static var space: StringParser<Character> 		{ return .char(" ") }
	public static var comma: StringParser<Character> 		{ return .char(",") }
	public static var dot: StringParser<Character> 			{ return .char(".") }
	public static var newLine: StringParser<Character> 		{ return .char("\n") }
	public static var cr: StringParser<Character> 			{ return .char("\r") }
	public static var crlf: StringParser<Character> 		{ return .char("\r\n") }
	public static var lparen: StringParser<Character> 		{ return .char("(") }
	public static var rparen: StringParser<Character> 		{ return .char(")") }
	public static var lbracket: StringParser<Character> 	{ return .char("[") }
	public static var rbracket: StringParser<Character> 	{ return .char("]") }
	public static var langle: StringParser<Character> 		{ return .char("<") }
	public static var rangle: StringParser<Character> 		{ return .char(">") }
	public static var lbrace: StringParser<Character> 		{ return .char("{") }
	public static var rbrace: StringParser<Character> 		{ return .char("}") }
	public static var semi: StringParser<Character> 		{ return .char(";") }
	public static var colon: StringParser<Character> 		{ return .char(":") }
	public static var squote: StringParser<Character> 		{ return .char("'") }
	public static var dquote: StringParser<Character>		{ return .char("\"") }
	public static var backslash: StringParser<Character>	{ return .char("\\") }
	public static var equals: StringParser<Character> 		{ return .char("=") }
	
	public static var endOfLine: StringParser<Character> {
		return .newLine <|> .crlf
	}
	
	public static func oneOf(_ input: String) -> StringParser<Character> {
		return .satisfy{ input.characters.contains($0) }
	}
	
	public static func noneOf(_ input: String) -> StringParser<Character> {
		return .satisfy{ !input.characters.contains($0) }
	}
}
