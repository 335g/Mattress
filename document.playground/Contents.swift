
import Either
import Mattress

let parser: CollectionParser<String.CharacterView> = CollectionParser("abcd".characters, ==)
parser.parse("abcd".characters).either(
	ifLeft: { print($0) },
	ifRight: { print($0) }
)

