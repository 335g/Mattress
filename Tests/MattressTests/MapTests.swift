
import XCTest
import Mattress
import Runes

class MapTests: XCTestCase {
	
	// MARK: - flatMap
	
	
	
	
	// MARK: - map
	
	func testMapTransformsParsedTree(){
		assertTree({ String($0) } <^> %123, [123], ==, "123")
	}
	
	// MARK: - ignore
	
	
}
