//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


import Quick
import Nimble
import Prelude
import Either
@testable import Mattress
import XCTest

final class RepetitionSpec: QuickSpec {
	override func spec() {
		describe("RepetitionParser"){
			describe(".many"){
				let parser = many(%"x")
				
				it("should parse empty"){
					expect(parser.check("")) == []
				}
				
				it("should parse one element"){
					expect(parser.check("x")) == ["x"]
				}
				
				it("should parse multiple elements"){
					expect(parser.check("xxx")) == ["x", "x", "x"]
				}
			}
			
			describe(".some"){
				let parser = some(%"x")
				
				it("should not parse empty"){
					expect(parser.check("")).to(beNil())
				}
				
				it("should parse one element"){
					expect(parser.check("x")) == ["x"]
				}
				
				it("should parse multiple elements"){
					expect(parser.check("xxx")) == ["x", "x", "x"]
				}
			}
			
			describe(".times"){
				it("should parse only same number of elements"){
					let parser = %"x" * 3
					
					expect(parser.check("x")).to(beNil())
					expect(parser.check("xx")).to(beNil())
					expect(parser.check("xxx")) == ["x", "x", "x"]
					expect(parser.check("xxxx")).to(beNil())
					expect(parser.check("xxxxx")).to(beNil())
				}
				
				it("should parse only elements in range"){
					let parser = %"x" * (0...1)
					
					expect(parser.check("")) == []
					expect(parser.check("x")) == ["x"]
					expect(parser.check("xx")).to(beNil())
					
					let parser2 = %"x" * (3...5)
					
					expect(parser2.check("")).to(beNil())
					expect(parser2.check("x")).to(beNil())
					expect(parser2.check("xx")).to(beNil())
					expect(parser2.check("xxx")) == ["x", "x", "x"]
					expect(parser2.check("xxxx")) == ["x", "x", "x", "x"]
					expect(parser2.check("xxxxx")) == ["x", "x", "x", "x", "x"]
					expect(parser2.check("xxxxxx")).to(beNil())
				}
			}
		}
	}
}
