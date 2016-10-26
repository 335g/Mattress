
import Either
import Mattress

let parser = %"abcd"
parser.parse("abcd".characters).either(
	ifLeft: { print($0) },
	ifRight: { print($0) }
)
