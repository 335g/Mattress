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
		
		describe("many(:endBy:)"){
			let parser = many(%"x", endBy: dot)
			
			it("should not parse any elements if it doesn't have the terminator.") {
				expect(try? parser.parse("x")).to(beNil())
				expect(try? parser.parse("xx")).to(beNil())
			}
			
			it("should parse empty"){
				expect(try? parser.parse("")) == []
			}
			
			it("should parse elements if it has the terminator.") {
				expect(try? parser.parse("x.")) == ["x"]
				expect(try? parser.parse("x.x.")) == ["x", "x"]
				expect(try? parser.parse("x.x.x.")) == ["x", "x", "x"]
			}
		}
		
		describe("many(:separatedBy:)"){
			let parser = many(%"x", separatedBy: comma)
			
			it("should parse no element."){
				expect(try? parser.parse("")) == []
			}
			
			it("should parse only element."){
				expect(try? parser.parse("x")) == ["x"]
			}
			
			it("should parse any elements if there are separated by separator."){
				expect(try? parser.parse("x,x")) == ["x", "x"]
				expect(try? parser.parse("x,x,x")) == ["x", "x", "x"]
			}
			
			it("should not parse elements with independent separator."){
				expect(try? parser.parse("x,")).to(beNil())
				expect(try? parser.parse(",x")).to(beNil())
				expect(try? parser.parse("x,x,")).to(beNil())
			}
		}
		
		describe("many(:until:)"){
			let parser = many(%"x", until: dot)
			
			it("should not parse any elements if it doesn't have the terminator.") {
				expect(try? parser.parse("")).to(beNil())
				expect(try? parser.parse("x")).to(beNil())
				expect(try? parser.parse("xx")).to(beNil())
			}
			
			it("should parse elements if it has the terminator.") {
				expect(try? parser.parse("x.")) == ["x"]
				expect(try? parser.parse("xx.")) == ["x", "x"]
				expect(try? parser.parse("xxx.")) == ["x", "x", "x"]
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
		
		describe("some(:endBy:)"){
			let parser = some(%"x", endBy: dot)
			
			it("should not parse any elements if not terminator.") {
				expect(try? parser.parse("x")).to(beNil())
				expect(try? parser.parse("xx")).to(beNil())
			}
			
			it("should not parse empty"){
				expect(try? parser.parse("")).to(beNil())
			}
			
			it("should parse elements if it has terminator.") {
				expect(try? parser.parse("x.")) == ["x"]
				expect(try? parser.parse("x.x.")) == ["x", "x"]
			}
		}
		
		describe("some(:separatedBy:)"){
			let parser = some(%"x", separatedBy: comma)
			
			it("should not parse no element."){
				expect(try? parser.parse("")).to(beNil())
			}
			
			it("should parse only element."){
				expect(try? parser.parse("x")) == ["x"]
			}
			
			it("should parse any elements if there are separated by separator."){
				expect(try? parser.parse("x,x")) == ["x", "x"]
				expect(try? parser.parse("x,x,x")) == ["x", "x", "x"]
			}
			
			it("should not parse elements with independent separator."){
				expect(try? parser.parse("x,")).to(beNil())
				expect(try? parser.parse(",x")).to(beNil())
				expect(try? parser.parse("x,x,")).to(beNil())
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
		
		describe("skipMany"){
			it("should parse multiple elements and no return"){
				let parser = skipMany(%"x")
				
				expect(try? parser.parse("")) == ()
				expect(try? parser.parse("x")) == ()
				expect(try? parser.parse("xx")) == ()
				expect(try? parser.parse("xxx")) == ()
				
			}
		}
		
		describe("skipSome"){
			it("should parse multiple elements and no return"){
				let parser = skipSome(%"x")
				
				expect(try? parser.parse("")).to(beNil())
				expect(try? parser.parse("x")) == ()
				expect(try? parser.parse("xx")) == ()
				expect(try? parser.parse("xxx")) == ()
				
			}
		}
	}
}
