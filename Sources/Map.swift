
import Runes

// MARK: - flatMap

public func >>- <C, T, U>(parser: Parser<C, T>, f: @escaping (T) -> Parser<C, U>) -> Parser<C, U> {
	return Parser<C, U> { input, index, ifFailure, ifSuccess in
		try parser.parse(input, at: index, ifFailure: ifFailure){
			try f($0).parse(input, at: $1, ifFailure: ifFailure, ifSuccess: ifSuccess)
		}
	}
}

// MARK: - map

public func <^> <C, T, U>(f: @escaping (T) -> U, parser: Parser<C, T>) -> Parser<C, U> {
	return parser >>- { .pure(f($0)) }
}

// MARK: - ignore

public func <^ <C, T, U>(left: T, right: Parser<C, U>) -> Parser<C, T> {
	return const(left) <^> right
}

// definition

infix operator <^ : RunesApplicativePrecedence
