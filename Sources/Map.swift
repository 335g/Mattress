
import Runes

public func >>- <C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, f: @escaping (T) throws -> Parser<C, U, A>.Function) rethrows -> Parser<C, U, A>.Function where C.Element: Equatable {
	return { input, index, ifSuccess, ifFailure in
		try parser(input, index, { t, i in try f(t)(input, i, ifSuccess, ifFailure) }, ifFailure)
	}
}

public func pure<C, T, A>(_ value: T) -> Parser<C, T, A>.Function where C.Element: Equatable {
	return { _, index, ifSuccess, _ in
		try ifSuccess(value, index)
	}
}

public func lift<C, T, U, V, A>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V, A>.Function where C.Element: Equatable {
	return pure(curry(f))
}

public func <^> <C, T, U, A>(f: @escaping (T) -> U, parser: @escaping Parser<C, T, A>.Function) rethrows -> Parser<C, U, A>.Function where C.Element: Equatable {
	return try parser >>- { pure(f($0)) }
}

public func <^ <C, T, U, A>(left: T, right: @escaping Parser<C, U, A>.Function) rethrows -> Parser<C, T, A>.Function where C.Element: Equatable {
	return try const(left) <^> right
}

//public func map<C, T, U, A>(_ f: @escaping (T) -> U) -> (@escaping Parser<C, T, A>.Function) rethrows -> Parser<C, U, A>.Function where C.Element: Equatable {
//	return { try f <^> $0 }
//}

infix operator <^ : RunesApplicativePrecedence
