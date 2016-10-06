
import Prelude
import Either
import Mattress

let parser1 = %"abc"
let parser2 = %"def"

if let parsed = parser1.parse("abc".characters).right {
	String(parsed)
}

let parser3 = String.init <^> %"1"

//let onetwo: ConcatParser<Parser<String.CharacterView>, Parser<String.CharacterView>> = %"1" >>- { _ in %"2" }

let onetwo = parser1.flatMap{ _ in parser2 }
if let parsed = onetwo.parse("abcdef".characters).right {
	String(parsed)
}

let onetwo2 = parser1 >>- { _ in parser2 }