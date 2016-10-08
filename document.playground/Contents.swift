
import Prelude
import Either
import Mattress

let parser1 = %"a"
let parser2 = %"b"
let parser3 = parser1 <|> parser2

if let parsed = parser3.parse("a".characters).right {
	parsed.either(
		ifLeft: String.init,
		ifRight: String.init
	)
}else {
	""
}

