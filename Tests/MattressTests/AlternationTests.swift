
import XCTest
import Mattress
import Runes

class AlternationTests: XCTestCase {
	
	// or
	
	func testOrParserConsumeOrNor(){
		var ab = lift(+) <*> "a"% <*> "b"%
		let ac = lift(+) <*> "a"% <*> "c"%
		var parser = ab <|> ac
		
		assertTree(parser, "ac", ==, "ac")
		XCTAssertNoThrow(try parser.parse("ac"))
		
		ab.consume()
		parser = ab <|> ac
		
		assertFailure(parser, "ac", message: "fails too 2nd parser `ac` because input `ac` is consumed at 1st parsing")
		XCTAssertThrowsError(try parser.parse("ac"), ""){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "ac".index("ac".startIndex, offsetBy: 1))
		}
		
	}
	
	// maybe
	
	func testMaybeParser(){
		let optional = "abc"%?
		
		assertTree(optional, "abc", ==, "abc", message: "When input matches it returns as it is")
		XCTAssertNoThrow(try optional.parse("abc"))
		
		assertTree(optional, "z", ==, nil, message: "nil when input is not match")
		
		XCTAssertThrowsError(try optional.parse("z"), "missed index"){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "z".startIndex)
		}
	}
}
