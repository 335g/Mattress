
import Runes

public typealias StringParser = Parser<String.CharacterView, String>
public typealias CharacterParser = Parser<String.CharacterView, Character>
public typealias CharacterArrayParser = Parser<String.CharacterView, [Character]>

extension Parser where C == String.CharacterView {
	public static func char(_ x: Character) -> CharacterParser {
		return .forward { $0 == x }
	}
	
	public static var tab: CharacterParser {
		return .char("\t")
	}
	
	public static var space: CharacterParser {
		return .char(" ")
	}
	
	public static var newLine: CharacterParser {
		return .char("\n")
	}
	
	public static var cr: CharacterParser {
		return .char("\r")
	}
	
	public static var crlf: CharacterParser {
		return .char("\r\n")
	}
	
	public static var endOfLine: CharacterParser {
		return .newLine <|> .crlf
	}
	
	public static func oneOf(_ input: String) -> CharacterParser {
		return .forward { input.characters.contains($0) }
	}
	
	public static func noneOf(_ input: String) -> CharacterParser {
		return .forward { !input.characters.contains($0) }
	}
}
