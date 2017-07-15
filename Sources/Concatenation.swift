
import Runes

public func <*> <C, T, U>(left: Parser<C, (T) -> U>, right: Parser<C, T>) -> Parser<C, U> {
	return left >>- { $0 <^> right }
}

public func <*> <C, T, U, V>(left: Parser<C, (T) -> (U, V)>, right: Parser<C, T>) -> Parser<C, (U, V)> {
	return left >>- { $0 <^> right }
}

public func <*> <C, T, U, V, W>(left: Parser<C, (T) -> (U, V, W)>, right: Parser<C, T>) -> Parser<C, (U, V, W)> {
	return left >>- { $0 <^> right }
}

public func <* <C, T, U>(left: Parser<C, T>, right: Parser<C, U>) -> Parser<C, T> {
	return left >>- { const($0) <^> right }
}

public func *> <C, T, U>(left: Parser<C, T>, right: Parser<C, U>) -> Parser<C, U> {
	return left >>- const(right)
}

