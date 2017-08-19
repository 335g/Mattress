
import XCTest
import Mattress
import Runes

class CombinationTests: XCTestCase {
	
	// between
	
	let braces: (StringParser<String>) -> StringParser<String> = between(.lbrace, and: .rbrace)
	
	func testBetweenCombinator(){
		assertTree(braces("aaa"%), "{aaa}", ==, "aaa")
	}
	
	func testBetweenCombinatorAcceptsEmptyString(){
		assertTree(braces(""%), "{}", ==, "")
	}
}
