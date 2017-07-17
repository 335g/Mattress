
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

private func assertExpected<T, U>(_ t: (T, T)?, _ pred: ((T, T), (U, U)) -> Bool, _ u: (U, U)?, message: String = "", file: StaticString = #file, line: UInt = #line) -> (T, T)? {
	switch (t, u) {
	case (.none, .none):
		return t
	case (.some(let (t1, t2)), .some(let (u1, u2))) where pred((t1, t2), (u1, u2)):
		return (t1, t2)
	case (.some(let (t1, t2)), .some(let (u1, u2))):
		return failure(message: "(\(String(reflecting: t1)), \(String(reflecting: t2))) did not match (\(String(reflecting: u1)), \(String(reflecting: u2))) . " + message, file: file, line: line)
	case (.some(let (t1, t2)), .none):
		return failure(message: "(\(String(reflecting: t1)), \(String(reflecting: t2)))  did not match nil. " + message)
	case (.none, .some(let (u1, u2))):
		return failure(message: "nil did not match (\(String(reflecting: u1)), \(String(reflecting: u2))) . " + message, file: file, line: line)
	}
}

private func check<C, T>(_ parser: Parser<C, T>, _ input: C) -> T? {
	return try? parser.parse(input, at: input.startIndex, ifFailure: { throw $0 }, ifSuccess: { t, _ in t as AnyObject }) as! T
}

private func check<C, T, U>(_ parser: Parser<C, (T, U)>, _ input: C) -> (T, U)? {
	return try? parser.parse(input, at: input.startIndex, ifFailure: { throw $0 }, ifSuccess: { t, _ in t as AnyObject }) as! (T, U)
}

@discardableResult
func assertTree<C, T>(_ parser: Parser<C, T>, _ input: C, _ match: (T, T) -> Bool, _ tree: T, message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
	return assertExpected(check(parser, input), match, tree)
}

@discardableResult
func assertTree<C, T>(_ parser: Parser<C, (T, T)>, _ input: C, _ match: ((T, T), (T, T)) -> Bool, _ tree: (T, T), message: String = "", file: StaticString = #file, line: UInt = #line) -> (T, T)? {
	return assertExpected(check(parser, input), match, tree)
}

@discardableResult
func assertTree<T>(_ parser: StringParser<T>, _ input: String, _ match: (T, T) -> Bool, _ tree: T, message: String = "", file: StaticString = #file, line: UInt = #line) -> T? {
	return assertTree(parser, input.characters, match, tree)
}

func assertFailure<C, T>(_ parser: Parser<C, T>, _ input: C, message: String = "", file: StaticString = #file, line: UInt = #line) {
	XCTAssertNil(check(parser, input), message, file: file, line: line)
}

func assertFailure<T>(_ parser: Parser<String.CharacterView, T>, _ input: String, message: String = "", file: StaticString = #file, line: UInt = #line) {
	XCTAssertNil(check(parser, input.characters), message, file: file, line: line)
}
