
import XCTest
@testable import Mattress

class ParserTests: XCTestCase {
	func testCollectionLiteralParser(){
		// Parser<C, C>
		
		var input: [Int]
		let parser: Parser<[Int], [Int]> = %[1,2,3,4]
		
		// parse without throwing if input matches
		assertTree(parser, [1,2,3,4], ==, [1,2,3,4])
		
		// throw if input is not match
		input = []
		XCTAssertThrowsError(try parser.parse(input), "empty"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = [0]
		XCTAssertThrowsError(try parser.parse(input), "not match element"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = [1]
		XCTAssertThrowsError(try parser.parse(input), "input is not enough"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex)	// `Collection` is checked by set
		}
		
		input = [1,2,4]
		XCTAssertThrowsError(try parser.parse(input), "input is not enough"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex) // `Collection` is checked by set
		}
		
		input = [1,2,3,4,5]
		XCTAssertThrowsError(try parser.parse(input), "input is over"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.index(input.startIndex, offsetBy: 4))
		}
	}
	
	func testElementLiteralParser(){
		// Parser<C, C.Element>
		
		var input: [Int]
		let parser: Parser<[Int], Int> = %5
		
		// parse without throwing if input matches
		assertTree(parser, [5], ==, 5)
		
		// throw if input is not match
		input = []
		XCTAssertThrowsError(try parser.parse(input), "empty"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = [1]
		XCTAssertThrowsError(try parser.parse(input), "not match element"){ err in
			let err = err as! ParsingError<[Int]>
			XCTAssertEqual(err.index, input.startIndex)
		}
	}
	
	func testCharacterLiteralParser(){
		// Parser<String.CharacterView, Character>
		
		var input: String.CharacterView
		let parser: StringParser<Character> = %"a"
		
		// parse without throwing if input matches
		assertTree(parser, "a", ==, "a")
		
		// throw if input is not match
		input = "".characters
		XCTAssertThrowsError(try parser.parse(input), "empty"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "b".characters
		XCTAssertThrowsError(try parser.parse(input), "not match element"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "ab".characters
		XCTAssertThrowsError(try parser.parse(input), "input is over"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.index(input.startIndex, offsetBy: 1))
		}
	}
	
	func testStringLiteralParser(){
		// Parser<String.CharacterView, String>
		
		var input: String
		let parser: StringParser<String> = %"abcd"
		
		// parse without throwing if input matches
		assertTree(parser, "abcd", ==, "abcd")
		
		// throw if input is not match
		input = ""
		XCTAssertThrowsError(try parser.parse(input), "empty"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "b"
		XCTAssertThrowsError(try parser.parse(input), "not match element"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "a"
		XCTAssertThrowsError(try parser.parse(input), "input is not enough"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)	// String is checked by set
		}
		
		input = "abz"
		XCTAssertThrowsError(try parser.parse(input), "input is not enough"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex) // String is checked by set
		}
		
		input = "abcde"
		XCTAssertThrowsError(try parser.parse(input), "input is over"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.index(input.startIndex, offsetBy: 4))
		}
	}
	
	func testClosedRangeLiteralParser(){
		// ClosedRange -> Parser<C, C.Element> where C.Element == ClosedRange.Base
		
		var input: String
		let parser: StringParser<Character> = %("a"..."f")
		
		// parse without throwing if input matches
		assertTree(parser, "a", ==, "a")
		assertTree(parser, "c", ==, "c")
		assertTree(parser, "f", ==, "f")
		
		// throw if input is not match
		input = ""
		XCTAssertThrowsError(try parser.parse(input), "empty"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "z"
		XCTAssertThrowsError(try parser.parse(input), "not match element"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "ab"
		XCTAssertThrowsError(try parser.parse(input), "input is over"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.index(input.startIndex, offsetBy: 1))
		}
	}
	
	func testNoneParser(){
		let parser: StringParser<Character> = .none
		var input: String.CharacterView
			
		input = "".characters
		XCTAssertThrowsError(try parser.parse(input), "not match"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "a".characters
		XCTAssertThrowsError(try parser.parse(input), "not match"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
		
		input = "aaaa".characters
		XCTAssertThrowsError(try parser.parse(input), "not match"){ err in
			let err = err as! ParsingError<String.CharacterView>
			XCTAssertEqual(err.index, input.startIndex)
		}
	}
	
	func testPureParser(){
		// ignore inputs
		assertTree(StringParser<String>.pure("a"), "b", ==, "a")
	}
	
	func testFinishedParser(){
		// anything is fine after end
		let parser = (%"a").finished()
		
		XCTAssertNoThrow(try? parser.parse("abcd"))
		assertTree(parser, "abcd", ==, "a")
	}
}
