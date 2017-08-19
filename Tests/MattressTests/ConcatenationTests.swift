
import XCTest
import Mattress
import Runes

class ConcatenationTests: XCTestCase {
	func testConcatenation(){
		let parser = lift(pair) <*> "x"% <*> "y"%
		
		assertFailure(parser, "x", message: "not tree if not both matching")
		XCTAssertThrowsError(try parser.parse("x"), ""){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "x".index("x".startIndex, offsetBy: 1))
		}
		assertTree(parser, "xy", ==, ("x", "y"))
		XCTAssertNoThrow(try parser.parse("xy"))
		
		assertTree(parser, "xyz", ==, ("x", "y"))
		XCTAssertThrowsError(try parser.parse("xyz"), ""){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xyz".index("xyz".startIndex, offsetBy: 2))
		}
	}
	
	func testConcatenation2(){
		let parser: StringParser<String> = "x"% <* "y"%
		
		assertTree(parser, "xy", ==, "x")
		XCTAssertNoThrow(try parser.parse("xy"))
	}
	
	func testConcatenation3(){
		let parser: StringParser<String> = "x"% *> "y"%
		
		assertTree(parser, "xy", ==, "y")
		XCTAssertNoThrow(try parser.parse("xy"))
	}
}
