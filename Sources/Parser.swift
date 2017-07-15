
// `T` finally converges to `A`
public struct Parser<C, T, A> where C: Collection {
	// There are cases where it is evaluated inside `ifSuccess` to chain other parser.
	public typealias IfSuccess = (T, C.Index) throws -> A
	
	// always throwing
	public typealias IfFailure = (ParsingError<C>) throws -> A
	
	// parser
	let parser: (C, C.Index, IfFailure, IfSuccess) throws -> A
	
	fileprivate func parse(_ input: C, ifFailure: @escaping IfFailure = { e in throw Error(e) }, ifSuccess: @escaping IfSuccess) throws -> A {
		return try parser(input, input.startIndex, ifFailure, ifSuccess)
	}
}

extension Parser where T == C.Element {
	private static func token(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index?) -> Parser<C, C.Element, A> {
		return Parser<C, C.Element, A>{ input, index, ifFailure, ifSuccess in
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
	
	public static func forward(satisfy: @escaping (C.Element) -> Bool) -> Parser<C, C.Element, A> {
		return token(satisfy) { input, index, elem in
			input.index(after: index)
		}
	}
}

// MARK: - parse

extension Parser where T == A {
	public func parse(_ input: C) throws -> T {
		return try parse(input, ifSuccess: { t, _ in t })
	}
}

extension Parser where C == String.CharacterView, T == A {
	public func parse(_ input: String) throws -> T {
		return try parse(input.characters, ifSuccess: { t, _ in t })
	}
}

extension Parser {
	public func parse(_ input: C, with f: @escaping (T) -> A) throws -> A {
		return try parse(input, ifSuccess: { t, _ in f(t) })
	}
}

// MARK: - `%`

prefix operator %

public prefix func %<C, A>(literal: C) -> Parser<C, C, A> where C.Element: Equatable {
	return Parser<C, C, A>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<A>(literal: String) -> Parser<String.CharacterView, String, A> {
	return Parser<String.CharacterView, String, A>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C, A>(literal: C.Element) -> Parser<C, C.Element, A> where C.Element: Equatable {
	return Parser<C, C.Element, A>{ input, index, ifFailure, ifSuccess in
		return index >= input.endIndex
			? try ifFailure(ParsingError(at: index, becauseOf: "`\(index)` is over endIndex."))
			: try {
				return input[index] == literal
					? try ifSuccess(literal, input.index(after: index))
					: try ifFailure(ParsingError(at: index, becauseOf: "not contains `\(literal)`"))
				}()
	}
}

public prefix func %<A>(literal: Character) -> Parser<String.CharacterView, Character, A> {
	return Parser<String.CharacterView, Character, A>{ input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(after: index))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C, A>(interval: ClosedRange<C.Element>) -> Parser<C, C.Element, A> {
	return Parser<C, C.Element, A>{ input, index, ifFailure, ifSuccess in
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
	public static func none() -> Parser<C, T, A> {
		return Parser<C, T, A> { input, index, ifFailure, _ in
			try ifFailure(ParsingError(at: index, becauseOf: "must not match '\(input)'."))
		}
	}
	
	public static func pure(_ value: T) -> Parser<C, T, A> {
		return Parser<C, T, A> { _, index, _, ifSuccess in
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

public func delay<C, T, A>(_ generator: @escaping () -> Parser<C, T, A>) -> Parser<C, T, A> {
	let memoized = memoize(generator)
	
	return Parser<C, T, A>{ try memoized().parser($0, $1, $2, $3) }
}

