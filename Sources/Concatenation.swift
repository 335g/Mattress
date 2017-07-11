
import Runes

public func <*> <C, T, U, A>(left: @escaping Parser<C, (T) -> U, A>.Function, right: @escaping Parser<C, T, A>.Function) -> Parser<C, U, A>.Function {
	return left >>- { $0 <^> right }
}

public func <* <C, T, U, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, U, A>.Function) -> Parser<C, T, A>.Function {
	return left >>- { const($0) <^> right }
}

public func *> <C, T, U, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, U, A>.Function) -> Parser<C, U, A>.Function {
	return left >>- const(right)
}

