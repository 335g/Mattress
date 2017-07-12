
import Cocoa
import Darwin
import Runes
import Mattress

typealias ColorParser<T> = Parser<String.CharacterView, T, NSColor>.Function

extension Character {
	static func + (lhs: Character, rhs: Character) -> String {
		return String(lhs) + String(rhs)
	}
}

func toComponent(_ str: String) -> CGFloat {
	return CGFloat(strtol(str, nil, 16)) / 255.0
}

let digit: ColorParser<Character> = %("0"..."9")
let lower: ColorParser<Character> = %("a"..."f")
let upper: ColorParser<Character> = %("A"..."F")
let hex: ColorParser<Character> = digit <|> lower <|> upper
let hex2: ColorParser<String> = lift(+) <*> hex <*> hex
let component1: ColorParser<CGFloat> = { toComponent($0 + $0) } <^> hex
let component2: ColorParser<CGFloat> = toComponent <^> hex2
let three: ColorParser<[CGFloat]> = component1 * 3
let six: ColorParser<[CGFloat]> = component2 * 3
let colour: ColorParser<NSColor> = { rgb in NSColor(calibratedRed: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1)  } <^> (%"#" *> (six <|> three))

let raddish = try? parse("#d52a41", with: colour)
let greenish = try? parse("#5a2", with: colour)
let blueish = try? parse("#5e8ca1", with: colour)

