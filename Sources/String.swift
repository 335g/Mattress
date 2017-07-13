
import Runes

public typealias StringParser<A> = Parser<String.CharacterView, String, A>
public typealias CharacterParser<A> = Parser<String.CharacterView, Character, A>
public typealias CharacterArrayParser<A> = Parser<String.CharacterView, [Character], A>

extension Parser where C == String.CharacterView {
	public static func char(_ x: Character) -> CharacterParser<A> {
		return .forward { $0 == x }
	}
	
	public static var tab: CharacterParser<A> {
		return .char("\t")
	}
	
	public static var space: CharacterParser<A> {
		return .char(" ")
	}
	
	public static var newLine: CharacterParser<A> {
		return .char("\n")
	}
	
	public static var cr: CharacterParser<A> {
		return .char("\r")
	}
	
	public static var crlf: CharacterParser<A> {
		return .char("\r\n")
	}
	
	public static var endOfLine: CharacterParser<A> {
		return .newLine <|> .crlf
	}
	
	public static func oneOf(_ input: String) -> CharacterParser<A> {
		return .forward { input.characters.contains($0) }
	}
	
	public static func noneOf(_ input: String) -> CharacterParser<A> {
		return .forward { !input.characters.contains($0) }
	}
}
