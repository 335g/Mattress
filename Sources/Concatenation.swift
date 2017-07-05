
import Runes

public func <*> <C, T, U, A>(left: @escaping Parser<C, (T) -> U, A>.Function, right: @escaping Parser<C, T, A>.Function) rethrows -> Parser<C, U, A>.Function where C.Element: Equatable {
	return try left >>- { try $0 <^> right }
}

public func <* <C, T, U, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, U, A>.Function) rethrows -> Parser<C, T, A>.Function where C.Element: Equatable {
	return try left >>- { x in try const(x) <^> right }
}

public func *> <C, T, U, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, U, A>.Function) rethrows -> Parser<C, U, A>.Function where C.Element: Equatable {
	return try left >>- const(right)
}

