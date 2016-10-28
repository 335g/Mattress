//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


import Quick
import Nimble
import Prelude
import Either
@testable import Mattress
import XCTest

final class RepetitionSpec: QuickSpec {
	override func spec() {
		describe("many"){
			let parser = many(%"x")
			
			it("should parse empty"){
				expect(try? parser.parse("")) == []
			}
			
			it("should parse one element"){
				expect(try? parser.parse("x")) == ["x"]
			}
			
			it("should parse multiple elements"){
				expect(try? parser.parse("xxx")) == ["x", "x", "x"]
			}
		}
		
		describe("some"){
			let parser = some(%"x")
			
			it("should not parse empty"){
				expect(try? parser.parse("")).to(beNil())
			}
			
			it("should parse one element"){
				expect(try? parser.parse("x")) == ["x"]
			}
			
			it("should parse multiple elements"){
				expect(try? parser.parse("xxx")) == ["x", "x", "x"]
			}
		}
		
		describe("times"){
			it("should parse only same number of elements"){
				let parser = %"x" * 3
				
				expect(try? parser.parse("x")).to(beNil())
				expect(try? parser.parse("xx")).to(beNil())
				expect(try? parser.parse("xxx")) == ["x", "x", "x"]
				expect(try? parser.parse("xxxx")).to(beNil())
				expect(try? parser.parse("xxxxx")).to(beNil())
			}
			
			it("should parse only elements in range"){
				let parser = %"x" * (0...1)
				
				expect(try? parser.parse("")) == []
				expect(try? parser.parse("x")) == ["x"]
				expect(try? parser.parse("xx")).to(beNil())
				
				let parser2 = %"x" * (3...5)
				
				expect(try? parser2.parse("")).to(beNil())
				expect(try? parser2.parse("x")).to(beNil())
				expect(try? parser2.parse("xx")).to(beNil())
				expect(try? parser2.parse("xxx")) == ["x", "x", "x"]
				expect(try? parser2.parse("xxxx")) == ["x", "x", "x", "x"]
				expect(try? parser2.parse("xxxxx")) == ["x", "x", "x", "x", "x"]
				expect(try? parser2.parse("xxxxxx")).to(beNil())
			}
		}
	}
}
