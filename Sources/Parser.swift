

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
	private let handler: (C, C.Index, IfFailure, IfSuccess) throws -> AnyObject
	
	// constructor
	public init(handler: @escaping (C, C.Index, IfFailure, IfSuccess) throws -> AnyObject) {
		self.handler = handler
	}
	
	func parse(_ input: C, at: C.Index, ifFailure: IfFailure, ifSuccess: IfSuccess) throws -> AnyObject {
		return try handler(input, at, ifFailure, ifSuccess)
	}
}

extension Parser: ParserProtocol {
	public typealias Target = C
	public typealias Tree = T
	
	public var parser: Parser<C, T> {
		return self
	}
}

extension Parser where T == C.Element {
	private static func token(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index?) -> Parser<C, C.Element> {
		return Parser<C, C.Element>{ input, index, ifFailure, ifSuccess in
			return index >= input.endIndex
				? try ifFailure(ParsingError(at: index, becauseOf: "`\(index)` is over endIndex."))
				: try {
					let elem = input[index]
					return pred(elem)
						? try ifSuccess(elem, index)
						: try ifFailure(ParsingError(at: index, becauseOf: "`\(input)` is not satisfied."))
					}()
		}
	}
	
	public static func forward(satisfy: @escaping (C.Element) -> Bool) -> Parser<C, C.Element> {
		return token(satisfy) { input, index, elem in
			input.index(after: index)
		}
	}
}

// MARK: - parse

extension Parser {
	fileprivate func parse(_ input: C, ifFailure: @escaping IfFailure = { throw $0 }, ifSuccess: @escaping IfSuccess) throws -> AnyObject {
		return try parse(input, at: input.startIndex, ifFailure: ifFailure, ifSuccess: ifSuccess)
	}
	
	public func parse(_ input: C) throws -> AnyObject {
		return try parse(input, ifSuccess: { t, _ in t as AnyObject })
	}
}

extension Parser where C == String.CharacterView {
	public func parse(_ input: String) throws -> AnyObject {
		return try parse(input.characters, ifSuccess: { t, _ in t as AnyObject })
	}
}

// MARK: - `%`

prefix operator %

public prefix func %<C>(literal: C) -> Parser<C, C> where C.Element: Equatable {
	return Parser<C, C>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %(literal: String) -> Parser<String.CharacterView, String> {
	return Parser<String.CharacterView, String>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C>(literal: C.Element) -> Parser<C, C.Element> where C.Element: Equatable {
	return Parser<C, C.Element>{ input, index, ifFailure, ifSuccess in
		return index >= input.endIndex
			? try ifFailure(ParsingError(at: index, becauseOf: "`\(index)` is over endIndex."))
			: try {
				return input[index] == literal
					? try ifSuccess(literal, input.index(after: index))
					: try ifFailure(ParsingError(at: index, becauseOf: "not contains `\(literal)`"))
				}()
	}
}

public prefix func %(literal: Character) -> Parser<String.CharacterView, Character> {
	return Parser<String.CharacterView, Character>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(after: index))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
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
	func contains(_ needle: String, at i: Index) -> Bool {
		guard let to = self.index(i, offsetBy: needle.count, limitedBy: self.endIndex) else {
			return false
		}
		
		return self[i..<to] == needle
	}
}

extension String.CharacterView {
	func contains(_ needle: String, at i: Index) -> Bool {
		return String(self).contains(needle, at: i)
	}
	
	func contains(_ needle: Character, at i: Index) -> Bool {
		return self.endIndex != i && self[i] == needle
	}
}

extension Collection where Element: Equatable {
	func contains(_ needle: Self, at i: Index) -> Bool {
		guard let first = needle.first, i != endIndex else {
			return false
		}
		
		if self[i] != first {
			return false
		}
		
		var i = i
		var j = needle.startIndex
		while self.formIndex(&i, offsetBy: 1, limitedBy: self.endIndex) && needle.formIndex(&j, offsetBy: 1, limitedBy: needle.endIndex) {
			if self[i] != needle[j] {
				return false
			}
		}
		
		return i != endIndex
	}
}

// MARK: - primitive

extension Parser {
	public static func none() -> Parser<C, T> {
		return Parser<C, T> { input, index, ifFailure, _ in
			try ifFailure(ParsingError(at: index, becauseOf: "must not match '\(input)'."))
		}
	}
	
	public static func pure(_ value: T) -> Parser<C, T> {
		return Parser<C, T> { _, index, _, ifSuccess in
			try ifSuccess(value, index)
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

