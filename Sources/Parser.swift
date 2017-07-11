
import Runes

// `T` finally converges to `A`
public enum Parser<C, T, A> where C: Collection {
	// There are cases where it is evaluated inside `ifSuccess` to chain other parser.
	public typealias IfSuccess = (T, C.Index) throws -> A
	
	// always throwing
	public typealias IfFailure = (ParsingError<C>) throws -> A
	
	public typealias Function = (C, C.Index, IfFailure, IfSuccess) throws -> A
}

public func satisfy<C, A>(pred: @escaping (C.Element) -> Bool) -> Parser<C, C.Element, A>.Function where C.Element: Equatable {
	return token(pred){ input, index, elem in
		input.index(after: index)
	}
}

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

// MARK: - `%`

prefix operator %

public prefix func %<A>(literal: String) -> Parser<String.CharacterView, String, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<A>(literal: Character) -> Parser<String.CharacterView, Character, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(after: index))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C, A>(literal: C) -> Parser<C, C, A>.Function where C.Element: Equatable {
	return { input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, input.index(index, offsetBy: literal.count))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'."))
	}
}

public prefix func %<C, A>(literal: C.Element) -> Parser<C, C.Element, A>.Function where C.Element: Equatable {
	return { input, index, ifFailure, ifSuccess in
		guard index < input.endIndex else {
			return try ifFailure(ParsingError(at: index, becauseOf: "\(index) is over endIndex."))
		}
		
		return input[index] == literal
			? try ifSuccess(literal, input.index(after: index))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(literal)'"))
	}
}

public prefix func %<C, A>(interval: ClosedRange<C.Element>) -> Parser<C, C.Element, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		guard index < input.endIndex else {
			return try ifFailure(ParsingError(at: index, becauseOf: "\(index) is over endIndex."))
		}
		
		let elem = input[index]
		
		return interval.contains(elem)
			? try ifSuccess(elem, input.index(after: index))
			: try ifFailure(ParsingError(at: index, becauseOf: "not contains '\(elem)'"))
	}
}

// MARK: - parse

public func parse<C, T>(_ input: C, with parser: @escaping Parser<C, T, T>.Function) throws -> T {
	let ifFailure: Parser<C, T, T>.IfFailure = { e in throw Error(e) }
	let ifSuccess: Parser<C, T, T>.IfSuccess = { t, _ in t }
	
	return try parser(input, input.startIndex, ifFailure, ifSuccess)
}

public func parse<T>(_ input: String, with parser: @escaping Parser<String.CharacterView, T, T>.Function) throws -> T {
	return try parse(input.characters, with: parser)
}

// MARK: - primitive functions

public func none<C, T, A>() -> Parser<C, T, A>.Function {
	return { input, index, ifFailure, _ in
		return try ifFailure(ParsingError(at: index, becauseOf: "must not match '\(input)'."))
	}
}

func token<C, A>(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index) -> Parser<C, C.Element, A>.Function {
	
	return { input, index, ifFailure, ifSuccess in
		if index == input.endIndex {
			return try ifFailure(ParsingError(at: index, becauseOf: "\(index) is over endIndex."))
		}else {
			let elem = input[index]
			
			return pred(elem)
				? try ifSuccess(elem, next(input, index, elem))
				: try ifFailure(ParsingError(at: index, becauseOf: "'\(input)' is not satisfied."))
		}
	}
}

public func pure<C, T, A>(_ value: T) -> Parser<C, T, A>.Function {
	return { _, index, ifFailure, ifSuccess in
		try ifSuccess(value, index)
	}
}

public func lift<C, T, U, V, A>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V, A>.Function {
	return pure(curry(f))
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

public func delay<C, T, A>(_ parser: @escaping () -> Parser<C, T, A>.Function) -> Parser<C, T, A>.Function {
	let memoized = memoize(parser)
	
	return { try memoized()($0, $1, $2, $3) }
}
