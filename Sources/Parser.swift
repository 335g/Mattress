
// T == A
public enum AParser<C, T, A> where C: Collection {
	// There are cases where it is evaluated inside `ifSuccess` to chain other parser.
	public typealias IfSuccess = (T, C.Index) throws -> A
	
	// always throwing
	public typealias IfFailure = (ParsingError<C>) throws -> A
	
	public typealias Function = (C, C.Index, IfFailure, IfSuccess) throws -> A
}

public typealias Parser<C, T> = AParser<C, T, Any> where C: Collection

public func satisfy<C>(pred: @escaping (C.Element) -> Bool) -> Parser<C, C.Element>.Function where C.Element: Equatable {
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
}

prefix operator %
public prefix func %(literal: String) -> Parser<String.CharacterView, String>.Function {
	return { input, index, ifFailure, ifSuccess in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

// MARK: - parse

public func parse<C, T>(_ parser: @escaping Parser<C, T>.Function, input: C) throws -> T {
	let ifFailure: AParser<C, T, T>.IfFailure = { e in throw Error(e) }
	let ifSuccess: AParser<C, T, T>.IfSuccess = { a, _ in a }
	if case let parser = parser as! AParser<C, T, T>.Function {
		return try parser(input, input.startIndex, ifFailure, ifSuccess)
	}
}

// MARK: - primitive functions

public func none<C, T>() -> Parser<C, T>.Function {
	return { _, index, ifFailure, _ in
		return try ifFailure(ParsingError<C>.notMatch(index))
	}
}

func token<C>(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index) -> Parser<C, C.Element>.Function where C.Element: Equatable {
	
	return { input, index, ifFailure, ifSuccess in
		if index == input.endIndex {
			return try ifFailure(.alreadyEnd(index))
		}else {
			let elem = input[index]
			
			return pred(elem)
				? try ifSuccess(elem, next(input, index, elem))
				: try ifFailure(.notSatisfaction(index))
		}
	}
}

public func pure<C, T>(_ value: T) -> Parser<C, T>.Function {
	return { _, index, ifFailure, ifSuccess in
		try ifSuccess(value, index)
	}
}

public func lift<C, T, U, V>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V>.Function {
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

public func delay<C, T>(_ parser: @escaping () -> Parser<C, T>.Function) -> Parser<C, T>.Function {
	let memoized = memoize(parser)
	
	return { try memoized()($0, $1, $2, $3) }
}
