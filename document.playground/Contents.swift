
import Either
import Mattress

//let parser = %"x" <|> %"xx"
//try parser.parse("xx")

let p = %"x" * 3
do {
	try p.parse("xx")
} catch ParsingError<String.Index>.notEnd(_) {
	""
} catch ParsingError<String.Index>.noReason(_) {
	""
} catch ParsingError<String.Index>.rangeOver(_) {
	""
} catch ParsingError<String.Index>.notEqual(_) {
	""
} catch ParsingError<String.Index>.debug(_) {
	""
} catch ParsingError<String.Index>.notAllowNoMatch(_) {
	""
}
