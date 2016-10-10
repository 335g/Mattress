
import Prelude
import Either
import Mattress

let parser1 = %"a"
let parser2 = %"b"
let parser3 = parser1 <|> parser2

//if let parsed = parser3.parse("b".characters).right {
//	parsed.either(
//		ifLeft: String.init,
//		ifRight: String.init
//	)
//}else {
//	""
//}

let parser4 = (%"x" <|> %"y") * (0...4)
if let parsed = parser4.parse("yyxx".characters).right {
	parsed.forEach{ x in
		print(x.either(
			ifLeft: String.init,
			ifRight: String.init
		))
	}
}

switch 4 {
case 0...4:
	"a"
default:
	"b"
}
