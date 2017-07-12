
import Runes

// MARK: - flatMap

public func >>- <C, T, U, A>(parser: Parser<C, T, A>, f: @escaping (T) -> Parser<C, U, A>) -> Parser<C, U, A> {
	return Parser<C, U, A> { input, index, ifFailure, ifSuccess in
		try parser.parser(input, index, ifFailure){
			try f($0).parser(input, $1, ifFailure, ifSuccess)
		}
	}
}

public func >>- <C, T, U, V, A>(parser: Parser<C, (T, U), A>, f: @escaping (T, U) -> Parser<C, V, A>) -> Parser<C, V, A> {
	return Parser<C, V, A> { input, index, ifFailure, ifSuccess in
		try parser.parser(input, index, ifFailure){
			try f($0.0, $0.1).parser(input, $1, ifFailure, ifSuccess)
		}
	}
}

public func >>- <C, T, U, V, W, A>(parser: Parser<C, (T, U, V), A>, f: @escaping (T, U, V) -> Parser<C, W, A>) -> Parser<C, W, A> {
	return Parser<C, W, A> { input, index, ifFailure, ifSuccess in
		try parser.parser(input, index, ifFailure){
			try f($0.0, $0.1, $0.2).parser(input, $1, ifFailure, ifSuccess)
		}
	}
}

// MARK: - map

public func <^> <C, T, U, A>(f: @escaping (T) -> U, parser: Parser<C, T, A>) -> Parser<C, U, A> {
	return parser >>- { .pure(f($0)) }
}

public func <^> <C, T, U, V, A>(f: @escaping (T, U) -> V, parser: Parser<C, (T, U), A>) -> Parser<C, V, A> {
	return parser >>- { .pure(f($0.0, $0.1))}
}

public func <^> <C, T, U, V, W, A>(f: @escaping (T, U, V) -> W, parser: Parser<C, (T, U, V), A>) -> Parser<C, W, A> {
	return parser >>- { .pure(f($0.0, $0.1, $0.2)) }
}

public func <^ <C, T, U, A>(left: T, right: Parser<C, U, A>) -> Parser<C, T, A> {
	return const(left) <^> right
}

public func <^ <C, T, U, V, A>(left: T, right: Parser<C, (U, V), A>) -> Parser<C, T, A> {
	return const(left) <^> right
}

public func <^ <C, T, U, V, W, A>(left: T, right: Parser<C, (U, V, W), A>) -> Parser<C, T, A> {
	return const(left) <^> right
}

// definition

infix operator <^ : RunesApplicativePrecedence
