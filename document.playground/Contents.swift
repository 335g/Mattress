
import Prelude
import Either
import Mattress

let parser = some(%"x")
if let parsed = parser.parse("".characters).right {
	
}else {
	""
}

