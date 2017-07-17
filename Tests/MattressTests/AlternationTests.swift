
import XCTest
import Mattress
import Runes

class AlternationTests: XCTestCase {
	
	// or
	
	func testOrParserConsumeOrNor(){
		var ab = lift(+) <*> %"a" <*> %"b"
		let ac = lift(+) <*> %"a" <*> %"c"
		var parser = ab <|> ac
		
		assertTree(parser, "ac", ==, "ac")
		XCTAssertNoThrow(try parser.parse("ac"))
		
		ab.consume()
		parser = ab <|> ac
		
		assertFailure(parser, "ac", message: "")
		XCTAssertThrowsError(try parser.parse("ac"), ""){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, "ac".index("ac".startIndex, offsetBy: 1))
		}
		
	}
	
	// maybe
	
	func testMaybeParser(){
		
	}
}
