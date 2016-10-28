//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Prelude
import Either
import SwiftCheck
@testable import Mattress

final class ParserSpec: XCTestCase {
	func testParse() {
		property("`Parser` should parse only one element.") <- forAll { (int: Int) in
			let parser: Parser<[Int]> = %int
			
			do {
				let result = try parser.parse([int])
				return result == int
			} catch {
				return false
			}
		}
	}
}
