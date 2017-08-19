
import Cocoa
import Darwin
import Runes
import Mattress

extension Character {
	static func + (lhs: Character, rhs: Character) -> String {
		return String("\(lhs)\(rhs)")
	}
}

func toComponent(_ str: String) -> CGFloat {
	return CGFloat(strtol(str, nil, 16)) / 255.0
}

let digit = ("0"..."9")%
let lower = ("a"..."f")%
let upper = ("A"..."F")%
let hex = digit <|> lower <|> upper
let hex2 = lift(+) <*> hex <*> hex
let component1 = { toComponent($0 + $0) } <^> hex
let component2 = toComponent <^> hex2
let three = component1 * 3
let six = component2 * 3
let colour: StringParser<NSColor> = { rgb in NSColor(calibratedRed: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1)  } <^> ("#"% *> (six <|> three))

let raddish = try? colour.parse("#d52a41")
let greenish = try? colour.parse("#5a2")
let blueish = try? colour.parse("#5e8ca1")

