
import Runes
import Mattress

let parser = %"a"

if let parsed = try? parse(parser, input: "a".characters) {
	print(parsed)
} else {
	print("not parsed")
}
