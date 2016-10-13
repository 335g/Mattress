//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Prelude
import Either
import Quick
import Nimble
import SwiftCheck
@testable import Mattress

final class MapSpec: XCTestCase {
	func testParse() {
		property("`MapParser` should transform from parsing") <- forAll { (int: Int) in
			let countup: (Int) -> Int = { $0 + 1 }
			let parser = MapParser(parser: Parser<[Int]>(int), mapping: countup)
			
			return parser.parse([int]).either(
				ifLeft: const(false),
				ifRight: { $0 == countup($0) }
			)
		}
	}
}
