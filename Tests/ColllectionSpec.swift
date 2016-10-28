//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Prelude
import Either
import SwiftCheck
@testable import Mattress

final class CollectionSpec: XCTestCase {
	func testParse() {
		property("`CollectionParser` should parse elements that is conformed Equatable.") <- forAll { (ints: [Int]) in
			let parser = CollectionParser(ints)
			
			do {
				let result = try parser.parse(ints)
				return result == ints
			} catch {
				return false
			}
		}
	}
}
