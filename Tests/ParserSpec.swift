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
			
			return parser.parse([int]).either(
				ifLeft: const(false),
				ifRight: { $0 == int }
			)
		}
	}
}
