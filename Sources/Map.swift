
import Runes

// MARK: - flatMap

public func >>- <C, T, U>(parser: Parser<C, T>, f: @escaping (T) -> Parser<C, U>) -> Parser<C, U> {
	return Parser<C, U> { input, index, ifFailure, ifSuccess in
		try parser.parse(input, at: index, ifFailure: ifFailure){
			try f($0).parse(input, at: $1, ifFailure: ifFailure, ifSuccess: ifSuccess)
		}
	}
}

public func >>- <C, T, U, V>(parser: Parser<C, (T, U)>, f: @escaping (T, U) -> Parser<C, V>) -> Parser<C, V> {
	return Parser<C, V> { input, index, ifFailure, ifSuccess in
		try parser.parse(input, at: index, ifFailure: ifFailure){
			try f($0.0, $0.1).parse(input, at: $1, ifFailure: ifFailure, ifSuccess: ifSuccess)
		}
	}
}

public func >>- <C, T, U, V, W>(parser: Parser<C, (T, U, V)>, f: @escaping (T, U, V) -> Parser<C, W>) -> Parser<C, W> {
	return Parser<C, W> { input, index, ifFailure, ifSuccess in
		try parser.parse(input, at: index, ifFailure: ifFailure){
			try f($0.0, $0.1, $0.2).parse(input, at: $1, ifFailure: ifFailure, ifSuccess: ifSuccess)
		}
	}
}

// MARK: - map

public func <^> <C, T, U>(f: @escaping (T) -> U, parser: Parser<C, T>) -> Parser<C, U> {
	return parser >>- { .pure(f($0)) }
}

public func <^> <C, T, U, V>(f: @escaping (T, U) -> V, parser: Parser<C, (T, U)>) -> Parser<C, V> {
	return parser >>- { .pure(f($0.0, $0.1))}
}

public func <^> <C, T, U, V, W>(f: @escaping (T, U, V) -> W, parser: Parser<C, (T, U, V)>) -> Parser<C, W> {
	return parser >>- { .pure(f($0.0, $0.1, $0.2)) }
}

// MARK: - ignore

public func <^ <C, T, U>(left: T, right: Parser<C, U>) -> Parser<C, T> {
	return const(left) <^> right
}

public func <^ <C, T, U, V>(left: T, right: Parser<C, (U, V)>) -> Parser<C, T> {
	return const(left) <^> right
}

public func <^ <C, T, U, V, W>(left: T, right: Parser<C, (U, V, W)>) -> Parser<C, T> {
	return const(left) <^> right
}

// definition

infix operator <^ : RunesApplicativePrecedence
