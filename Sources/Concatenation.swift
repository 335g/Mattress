
import Runes

public func <*> <C, T, U>(left: @escaping Parser<C, (T) -> U>.Function, right: @escaping Parser<C, T>.Function) -> Parser<C, U>.Function {
	return left >>- { $0 <^> right }
}

public func <* <C, T, U>(left: @escaping Parser<C, T>.Function, right: @escaping Parser<C, U>.Function) -> Parser<C, T>.Function {
	return left >>- { const($0) <^> right }
}

public func *> <C, T, U>(left: @escaping Parser<C, T>.Function, right: @escaping Parser<C, U>.Function) -> Parser<C, U>.Function {
	return left >>- const(right)
}
