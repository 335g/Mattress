//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


@testable import Mattress
import Prelude
import Either
import Quick
import Nimble

final class AlternationSpec: QuickSpec {
	override func spec() {
		describe("AltParser"){
			it("should parse either left or right"){
				let parser = %"x" <|> %"y"
				
				expect(try? parser.parse("x")) == "x"
				expect(try? parser.parse("y")) == "y"
			}
			
			it("should parse in favor of the left"){
				let parser = %"x" <|> %"xx"
				
				expect(try? parser.parse("x")) == "x"
				expect(try? parser.parse("xx")).to(beNil())
			}
		}
	}
}
