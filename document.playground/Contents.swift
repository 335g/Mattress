
import Either
import Mattress

let parser = %"abcd"
parser.parse("abcd".characters).either(
	ifLeft: { print($0) },
	ifRight: { print($0) }
)

let parser2 = %("a"..."z")
parser2.parse("b".characters).either(
	ifLeft: { print($0) },
	ifRight: { print($0) }
)