
import Runes

public protocol ParserProtocol {
	associatedtype Target: Collection
	associatedtype Tree
	
	var parser: Parser<Target, Tree> { get }
}

// `AnyObject` finally converges to `T`
public struct Parser<C, T> where C: Collection {
	// There are cases where it is evaluated inside `ifSuccess` to chain other parser.
	public typealias IfSuccess = (T, C.Index) throws -> AnyObject
	
	// always throwing
	public typealias IfFailure = (ParsingError<C>) throws -> AnyObject
	
	// parser
	private let unparser: (C, C.Index, IfFailure, IfSuccess) throws -> AnyObject
	
	// wheather it consumes when first parser fails  (cf. `or`
	var consumeType: Bool = false
	
	// constructor
	public init(unparser: @escaping (C, C.Index, IfFailure, IfSuccess) throws -> AnyObject) {
		self.unparser = unparser
	}
	
	func parse(_ input: C, at index: C.Index, ifFailure: IfFailure, ifSuccess: IfSuccess) throws -> AnyObject {
		return try unparser(input, index, ifFailure, ifSuccess)
	}
}

extension Parser: ParserProtocol {
	public typealias Target = C
	public typealias Tree = T
	
	public var parser: Parser<C, T> {
		return self
	}
}

extension Parser {
	public static func satisfy(where pred: @escaping (C.Element) -> Bool) -> Parser<C, C.Element> {
		return Parser<C, C.Element>{ input, index, ifFailure, ifSuccess in
			return index >= input.endIndex
				? try ifFailure(ParsingError(at: index, becauseOf: "\(index) is over endIndex."))
				: try {
					let elem = input[index]
					return pred(elem)
						? try ifSuccess(elem, input.index(after: index))
						: try ifFailure(ParsingError(at: index, becauseOf: "\(input) is not satisfied."))
				}()
		}
	}
}

// MARK: - parse

extension Parser {
	fileprivate func parse(_ input: C, ifFailure: @escaping IfFailure = { throw $0 }, ifSuccess: @escaping IfSuccess) throws -> T {
		return try parse(input, at: input.startIndex, ifFailure: ifFailure, ifSuccess: ifSuccess) as! T
	}
	
	public func parse(_ input: C) throws -> T {
		return try parse(input){ tree, index in
			if index == input.endIndex {
				return tree as AnyObject
			} else {
				throw ParsingError<C>(at: index, becauseOf: "\(index) is not equal to input.endIndex.")
			}
		}
	}
}

extension Parser where C == String.CharacterView {
	public func parse(_ input: String) throws -> T {
		return try parse(input.characters){ tree, index in
			if index == input.endIndex {
				return tree as AnyObject
			} else {
				throw ParsingError<C>(at: index, becauseOf: "\(index) is not equal to input.endIndex.")
			}
		}
	}
}

// MARK: - `%`

prefix operator %

public prefix func %<C>(literal: C) -> Parser<C, C> where C.Element: Equatable {
	return Parser<C, C>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, from: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError<C>(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C>(literal: C.Element) -> Parser<C, C.Element> where C.Element: Equatable {
	return Parser<C, C.Element>{ input, index, ifFailure, ifSuccess in
		return index >= input.endIndex
			? try ifFailure(ParsingError<C>(at: index, becauseOf: "`\(index)` is over endIndex."))
			: try {
				return input[index] == literal
					? try ifSuccess(literal, input.index(after: index))
					: try ifFailure(ParsingError<C>(at: index, becauseOf: "not contains `\(literal)`"))
				}()
	}
}

public prefix func %(literal: String) -> Parser<String.CharacterView, String> {
	return Parser<String.CharacterView, String>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, from: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError<String.CharacterView>(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %(literal: Character) -> Parser<String.CharacterView, Character> {
	return Parser<String.CharacterView, Character>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(after: index))
			: try ifFailure(ParsingError<String.CharacterView>(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C>(interval: ClosedRange<C.Element>) -> Parser<C, C.Element> {
	return Parser<C, C.Element>{ input, index, ifFailure, ifSuccess in
		return index >= input.endIndex
			? try ifFailure(ParsingError(at: index, becauseOf: "`\(index)` is over endIndex."))
			: try {
				let elem = input[index]
				return interval.contains(elem)
					? try ifSuccess(elem, input.index(after: index))
					: try ifFailure(ParsingError(at: index, becauseOf: "not contains `\(elem)`"))
				}()
	}
}


// MARK: - Satisfier

extension String {
	func contains(_ needle: String, from i: Index) -> Bool {
		guard let to = self.index(i, offsetBy: needle.count, limitedBy: self.endIndex) else {
			return false
		}
		
		return self[i..<to] == needle
	}
}

extension String.CharacterView {
	func contains(_ needle: String, from i: Index) -> Bool {
		return String(self).contains(needle, from: i)
	}
	
	func contains(_ needle: Character, at i: Index) -> Bool {
		return self.startIndex <= i
			&& i < self.endIndex
			&& self[i] == needle
	}
}

extension Collection where Element: Equatable {
	func contains(_ needle: Self, from: Index) -> Bool {
		guard
			self.startIndex <= from && from < self.endIndex,
			let to = self.index(from, offsetBy: needle.count, limitedBy: self.endIndex) else { return false }
		
		return zip(self[from..<to], needle).lazy.reduce(true){ $0 && $1.0 == $1.1 }
	}
}

// MARK: - primitive

extension Parser {
	public static var none: Parser<C, T> {
		return Parser<C, T> { input, index, ifFailure, _ in
			try ifFailure(ParsingError(at: index, becauseOf: "must not match '\(input)'."))
		}
	}
	
	public static func pure(_ value: T) -> Parser<C, T> {
		return Parser<C, T> { _, index, _, ifSuccess in
			try ifSuccess(value, index)
		}
	}
	
	public func finished() -> Parser<C, T> {
		return self >>- { tree in
			return Parser<C, T>{ input, _, _, ifSuccess in
				return try ifSuccess(tree, input.endIndex)
			}
		}
	}
}

private func memoize<T>(_ f: @escaping () -> T) -> () -> T {
	var memoized: T!
	
	return {
		if memoized == nil {
			memoized = f()
		}
		
		return memoized
	}
}

public func delay<C, T>(_ generator: @escaping () -> Parser<C, T>) -> Parser<C, T> {
	let memoized = memoize(generator)
	
	return Parser<C, T>{ try memoized().parse($0, at: $1, ifFailure: $2, ifSuccess: $3) }
}

