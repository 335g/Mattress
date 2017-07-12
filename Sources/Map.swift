
import Runes

public func >>- <C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, f: @escaping (T) -> Parser<C, U, A>.Function) -> Parser<C, U, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		try parser(input, index, ifFailure){ try f($0)(input, $1, ifFailure, ifSuccess) }
	}
}

public func >>- <C, T, U, V, A>(parser: @escaping Parser<C, (T, U), A>.Function, f: @escaping (T, U) -> Parser<C, V, A>.Function) -> Parser<C, V, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		try parser(input, index, ifFailure){ try f($0.0, $0.1)(input, $1, ifFailure, ifSuccess) }
	}
}

public func <^> <C, T, U, A>(f: @escaping (T) -> U, parser: @escaping Parser<C, T, A>.Function) -> Parser<C, U, A>.Function {
	return parser >>- { pure(f($0)) }
}

public func <^> <C, T, U, V, A>(f: @escaping (T, U) -> V, parser: @escaping Parser<C, (T, U), A>.Function) -> Parser<C, V, A>.Function {
	return parser >>- { pure(f($0, $1)) }
}

public func <^ <C, T, U, A>(left: T, right: @escaping Parser<C, U, A>.Function) -> Parser<C, T, A>.Function {
	return const(left) <^> right
}

// definition

infix operator <^ : RunesApplicativePrecedence
