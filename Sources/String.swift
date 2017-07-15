
import Runes

public typealias StringParser<T> = Parser<String.CharacterView, T>

extension Parser where C == String.CharacterView {
	public static func char(_ x: Character) -> StringParser<Character> {
		return .forward { $0 == x }
	}
	
	public static var tab: StringParser<Character> {
		return .char("\t")
	}
	
	public static var space: StringParser<Character> {
		return .char(" ")
	}
	
	public static var newLine: StringParser<Character> {
		return .char("\n")
	}
	
	public static var cr: StringParser<Character> {
		return .char("\r")
	}
	
	public static var crlf: StringParser<Character> {
		return .char("\r\n")
	}
	
	public static var endOfLine: StringParser<Character> {
		return .newLine <|> .crlf
	}
	
	public static func oneOf(_ input: String) -> StringParser<Character> {
		return .forward { input.characters.contains($0) }
	}
	
	public static func noneOf(_ input: String) -> StringParser<Character> {
		return .forward { !input.characters.contains($0) }
	}
}
