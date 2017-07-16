
import XCTest
@testable import Mattress

private func failure<T>(message: String, file: StaticString = #file, line: UInt = #line) -> T? {
	XCTFail(message, file: file, line: line)
	return nil
}

private func assertExpected<T, U>(_ t: T?, _ pred: (T, U) -> Bool, _ u: U?, message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
	switch (t, u) {
	case (.none, .none):
		return t
	case (.some(let t), .some(let u)) where pred(t, u):
		return t
	case (.some(let t), .some(let u)):
		return failure(message: "\(String(reflecting: t)) did not match \(String(reflecting: u)). " + message, file: file, line: line)
	case (.some(let t), .none):
		return failure(message: "\(String(reflecting: t)) did not match nil. " + message)
	case (.none, .some(let u)):
		return failure(message: "nil did not match \(String(reflecting: u)). " + message, file: file, line: line)
	}
}

private func check<C, T>(_ parser: Parser<C, T>, _ input: C) -> T? {
	return try? parser.parse(input, at: input.startIndex, ifFailure: { throw $0 }, ifSuccess: { t, _ in t as AnyObject }) as! T
}

@discardableResult
func assertTree<C, T>(_ parser: Parser<C, T>, _ input: C, _ match: (T, T) -> Bool, _ tree: T, message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
//	let parsed = try? parser.parse(input, at: input.startIndex,
//	                               ifFailure: { throw $0 },
//	                               ifSuccess: { t, _ in t as AnyObject }) as! T
	return assertExpected(check(parser, input), match, tree)
}

@discardableResult
func assertTree<T>(_ parser: StringParser<T>, _ input: String, _ match: (T, T) -> Bool, _ tree: T, message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
	return assertTree(parser, input.characters, match, tree)
}

func assertFailure<C, T>(_ parser: Parser<C, T>, _ input: C) {
	XCTAssertNil(check(parser, input))
}

func assertFailure<T>(_ parser: Parser<String.CharacterView, T>, _ input: String) {
	XCTAssertNil(check(parser, input.characters))
}
