//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


import Quick
import Nimble
import Prelude
import Either
@testable import Mattress
import XCTest

final class ConcaternationSpec: QuickSpec {
	override func spec() {
		describe(">>-"){
			it(""){
				let parser = %"x" >>- const(%"y")
				expect( parser.check("xy") ) == "y"
			}
		}
	}
}
