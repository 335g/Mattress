//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


@testable import Mattress
import Either
import Quick
import Nimble

final class AlternationSpec: QuickSpec {
	override func spec() {
		describe("AltParser"){
			it("should parse either left or right"){
				let parser = %"x" <|> %"y"
				
				expect(parser.check("x")?.extract()) == "x"
				expect(parser.check("y")?.extract()) == "y"
			}
			
			it("should parse in favor of the left"){
				let parser = %"x" <|> %"xy"
				
				expect(parser.check("x")?.extract()) == "x"
				expect(parser.check("xy")?.extract()).to(beNil())
			}
		}
	}
}

extension EitherProtocol where Left == Right {
	func extract() -> Right {
		return either(ifLeft: { $0 }, ifRight: { $0 })
	}
}
