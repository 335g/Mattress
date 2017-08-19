
import Runes

public func <*> <C, T, U>(left: Parser<C, (T) -> U>, right: Parser<C, T>) -> Parser<C, U> {
	return left >>- { $0 <^> right }
}

public func <* <C, T, U>(left: Parser<C, T>, right: Parser<C, U>) -> Parser<C, T> {
	return left >>- { const($0) <^> right }
}

public func *> <C, T, U>(left: Parser<C, T>, right: Parser<C, U>) -> Parser<C, U> {
	return left >>- const(right)
}

