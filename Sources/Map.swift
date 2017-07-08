
import Runes

public func >>- <C, T, U>(parser: @escaping Parser<C, T>.Function, f: @escaping (T) -> Parser<C, U>.Function) -> Parser<C, U>.Function {
	return { input, index, ifFailure, ifSuccess in
		try parser(input, index, ifFailure){ try f($0)(input, $1, ifFailure, ifSuccess) }
	}
}

public func <^> <C, T, U>(f: @escaping (T) -> U, parser: @escaping Parser<C, T>.Function) -> Parser<C, U>.Function {
	return parser >>- { pure(f($0)) }
}

public func <^ <C, T, U>(left: T, right: @escaping Parser<C, U>.Function) -> Parser<C, T>.Function {
	return const(left) <^> right
}

// definition

infix operator <^ : RunesApplicativePrecedence
