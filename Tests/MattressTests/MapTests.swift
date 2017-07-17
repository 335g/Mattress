
import XCTest
import Mattress
import Runes

private struct Tree<T> where T: Equatable {
	let value: T
	let children: [Tree] = []
}

extension Tree {
	static func == (lhs: Tree<T>, rhs: Tree<T>) -> Bool {
		return lhs.value == rhs.value
			&& lhs.children.count == rhs.children.count
			&& zip(lhs.children, rhs.children).lazy.reduce(true){ $0 && $1.0 == $1.1 }
	}
}

class MapTests: XCTestCase {
	
	// MARK: - flatMap
	
	func testFlatMapParsers(){
		
	}
	
	
	// MARK: - map
	
	func testMapTransformsParsedTree(){
		assertTree({ String($0) } <^> %123, [123], ==, "123")
	}
	
	// MARK: - ignore
	
	
}
