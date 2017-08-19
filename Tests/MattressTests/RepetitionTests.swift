
import XCTest
import Mattress
import Runes

class RepetitionTests: XCTestCase {
	
	// many
	
	func testManyParser(){
		let parser = many(%"x")
		
		assertTree(parser, "y", ==, [], message: "`many` parses not matched element without advance.")
		XCTAssertThrowsError(try parser.parse("y"), "`many` parses not matched element without advance."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "y".startIndex)
		}
		
		assertTree(parser, "x", ==, ["x"], message: "`many` parses matched single element.")
		XCTAssertNoThrow(try parser.parse("x"))
		
		assertTree(parser, "xx", ==, ["x", "x"], message: "`many` parses matched multiple elements")
		XCTAssertNoThrow(try parser.parse("xx"))
		
		assertTree(parser, "xxx", ==, ["x", "x", "x"], message: "`many` parses matched multiple elements")
		XCTAssertNoThrow(try parser.parse("xxx"))
	}
	
	// some
	
	func testSomeParser(){
		let parser = some(%"x")
		
		assertFailure(parser, "y", message: "`some` doesn't parse not matched element.")
		XCTAssertThrowsError(try parser.parse("y"), "`some` doesn't parse not matched element."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "y".startIndex)
		}
		
		assertTree(parser, "x", ==, ["x"], message: "`some` parses matched single element.")
		XCTAssertNoThrow(try parser.parse("x"))
		
		assertTree(parser, "xx", ==, ["x", "x"], message: "`some` parses matched multiple elements")
		XCTAssertNoThrow(try parser.parse("xx"))
	}
	
	// ntimes
	
	func test0timesParser(){
		let zeroTimes = %"x" * 0	// == 0.times(%"x")
		
		assertTree(zeroTimes, "y", ==, [], message: "0.`times` parses not matched element without advance.")
		XCTAssertThrowsError(try zeroTimes.parse("y"), "0.`times` parses not matched element without advance."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "y".startIndex)
		}
		
		assertTree(zeroTimes, "x", ==, [], message: "0.`times` parses matched element without advance and tree.")
		XCTAssertThrowsError(try zeroTimes.parse("x"), "0.`times` parses matched element without advance and tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "x".startIndex)
		}
	}
	
	func test2timesParser(){
		let twoTimes = %"x" * 2	// == 2.times(%"x")
		
		assertFailure(twoTimes, "y", message: "2.`times` doesn't parse not matched element.")
		XCTAssertThrowsError(try twoTimes.parse("y"), "2.`times` doesn't parse not matched element."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "y".startIndex)
		}
		
		assertFailure(twoTimes, "x", message: "2.`times` doesn't parse matched elements when the number is less than 2.")
		XCTAssertThrowsError(try twoTimes.parse("x"), "2.`times` doesn't parse matched elements when the number is less than 2."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "x".index("x".startIndex, offsetBy: 1))
		}
		
		assertTree(twoTimes, "xx", ==, ["x", "x"], message: "2.`times` parses matched 2 elements with advance and tree.")
		XCTAssertNoThrow(try twoTimes.parse("xx"), "2.`times` parses matched 2 elements with advance and tree.")
		
		assertTree(twoTimes, "xxx", ==, ["x", "x"], message: "2.`times` parses matched over 3 elements with 2 advance and 2 tree.")
		XCTAssertThrowsError(try twoTimes.parse("xxx"), "2.`times` parses matched over 3 elements with 2 advance and 2 tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xxx".index("xxx".startIndex, offsetBy: 2))
		}
	}
	
	// CountableClosedRange
	
	func testZeroOverCountableClosedRangeParser(){
		let parser = %"x" * (0...1)	// == (0...1).times(%"x")
		
		assertTree(parser, "", ==, [])
		XCTAssertNoThrow(try parser.parse(""))
		
		assertTree(parser, "x", ==, ["x"])
		XCTAssertNoThrow(try parser.parse("x"))
		
		assertTree(parser, "xx", ==, ["x"], message: "(0...1).`times` parses matched 1 element with 1 advance and tree.")
		XCTAssertThrowsError(try parser.parse("xx"), "(0...1).`times` parses matched 1 element with 1 advance and tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xxx".index("xxx".startIndex, offsetBy: 1))
		}
	}
	
	func testNotZeroOverCountableClosedRangeParser(){
		let parser = %"x" * (2...3)	// == (2...3).times(%"x")
		
		assertFailure(parser, "", message: "(2...3).`times` doesn't parse empty.")
		XCTAssertThrowsError(try parser.parse(""), "(2...3).`times` doesn't parse empty."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "".startIndex)
		}
		
		assertFailure(parser, "x", message: "(2...3).`times` doesn't parse 1 matched element.")
		XCTAssertThrowsError(try parser.parse("x"), "(2...3).`times` doesn't parse 1 matched element."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "x".startIndex)
		}
		
		
		assertTree(parser, "xx", ==, ["x", "x"])
		XCTAssertNoThrow(try parser.parse("xx"))
		
		assertTree(parser, "xxx", ==, ["x", "x", "x"])
		XCTAssertNoThrow(try parser.parse("xxx"))
		
		
		assertTree(parser, "xxxx", == , ["x", "x", "x"], message: "(2...3).`times` parse over 3 matched elements with 3 advance and tree.")
		XCTAssertThrowsError(try parser.parse("xxxx"), "(2...3).`times` parse over 3 matched elements with 3 advance and tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xxxx".index("xxxx".startIndex, offsetBy: 3))
		}
	}
	
	// CountableRange
	
	func testZeroOverCountableRangeParser(){
		let parser = %"x" * (0..<2)	// == (0..<2).times(%"x")
		
		assertTree(parser, "", ==, [])
		XCTAssertNoThrow(try parser.parse(""))
		
		assertTree(parser, "x", ==, ["x"])
		XCTAssertNoThrow(try parser.parse("x"))
		
		assertTree(parser, "xx", ==, ["x"], message: "(0..<2).`times` parses matched 1 element with 1 advance and tree.")
		XCTAssertThrowsError(try parser.parse("xx"), "(0..<2).`times` parses matched 1 element with 1 advance and tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xxx".index("xxx".startIndex, offsetBy: 1))
		}
	}
	
	func testNotZeroOverCountableRangeParser(){
		let parser = %"x" * (2..<4)	// == (2..<4).times(%"x")
		
		assertFailure(parser, "", message: "(2..<4).`times` doesn't parse empty.")
		XCTAssertThrowsError(try parser.parse(""), "(2..<4).`times` doesn't parse empty."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "".startIndex)
		}
		
		assertFailure(parser, "x", message: "(2..<4).`times` doesn't parse 1 matched element.")
		XCTAssertThrowsError(try parser.parse("x"), "(2..<4).`times` doesn't parse 1 matched element."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "x".startIndex)
		}
		
		
		assertTree(parser, "xx", ==, ["x", "x"])
		XCTAssertNoThrow(try parser.parse("xx"))
		
		assertTree(parser, "xxx", ==, ["x", "x", "x"])
		XCTAssertNoThrow(try parser.parse("xxx"))
		
		
		assertTree(parser, "xxxx", == , ["x", "x", "x"], message: "(2..<4).`times` parse over 3 matched elements with 3 advance and tree.")
		XCTAssertThrowsError(try parser.parse("xxxx"), "(2..<4).`times` parse over 3 matched elements with 3 advance and tree."){ err in
			let err = err as! ParsingError<String>
			XCTAssertEqual(err.index, "xxxx".index("xxxx".startIndex, offsetBy: 3))
		}
	}
	
	// sep
	
	func testSepParser(){
		let parser = (%("a"..."c")).isSeparated(by: .comma)	// == sep(by: .comma, parser: %("a"..."c"))
		
		assertTree(parser, "", ==, [])
		assertTree(parser, "a", ==, ["a"])
		assertTree(parser, "a,c", ==, ["a", "c"])
		assertTree(parser, "b,a,c", ==, ["b", "a", "c"])
		
		XCTAssertNoThrow(try parser.parse(""))
		XCTAssertNoThrow(try parser.parse("a"))
		XCTAssertNoThrow(try parser.parse("a,c"))
		XCTAssertNoThrow(try parser.parse("b,a,c"))
	}
	
	func testSep1Parser(){
		let parser = (%("a"..."c")).isSeparatedByAtLeastOne(by: .comma)	// == sep1(by: .comma, parser: %("a"..."c"))
		
		assertFailure(parser, "", message: "must input at least one")
		assertTree(parser, "a", ==, ["a"])
		assertTree(parser, "a,b", ==, ["a", "b"])
		assertTree(parser, "a,b,c", ==, ["a", "b", "c"])
		
		XCTAssertNoThrow(try parser.parse("a"))
		XCTAssertNoThrow(try parser.parse("a,b"))
		XCTAssertNoThrow(try parser.parse("a,b,c"))
	}
	
	// end
	
	func testEndParser(){
		let abc: StringParser<Character> = %("a"..."c")
		let parser = abc.isTerminated(by: .dot)	// == end(by: .dot, parser: %("a"..."c"))
		
		assertTree(parser, "", ==, [])
		assertTree(parser, "a.", ==, ["a"])
		assertTree(parser, "a.b.", ==, ["a", "b"])
		assertTree(parser, "a.b.c.", ==, ["a", "b", "c"])
		
		XCTAssertNoThrow(try parser.parse(""))
		XCTAssertNoThrow(try parser.parse("a."))
		XCTAssertNoThrow(try parser.parse("a.b."))
		XCTAssertNoThrow(try parser.parse("a.b.c."))
	}
	
	func testEnd1Parser(){
		let abc: StringParser<Character> = %("a"..."c")
		let parser = abc.isTerminatedByAtLeastOne(by: .dot)	// == end1(by: .dot, parser: %("a"..."c"))
		
		assertFailure(parser, "", message: "must input at least one")
		assertTree(parser, "a.", ==, ["a"])
		assertTree(parser, "a.b.", ==, ["a", "b"])
		assertTree(parser, "a.b.c.", ==, ["a", "b", "c"])
		
		XCTAssertNoThrow(try parser.parse("a."))
		XCTAssertNoThrow(try parser.parse("a.b."))
		XCTAssertNoThrow(try parser.parse("a.b.c."))
	}
}

