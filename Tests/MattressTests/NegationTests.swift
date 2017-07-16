
import XCTest
import Mattress

class NagationTests: XCTestCase {
	func testIsNotParser(){
		let notA = not(%"a")
		
		assertFailure(notA, "a")
	}
}

