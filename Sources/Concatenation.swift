
import Runes

public func <*> <C, T, U, A>(left: Parser<C, (T) -> U, A>, right: Parser<C, T, A>) -> Parser<C, U, A> {
	return left >>- { $0 <^> right }
}

public func <* <C, T, U, A>(left: Parser<C, T, A>, right: Parser<C, U, A>) -> Parser<C, T, A> {
	return left >>- { const($0) <^> right }
}

public func *> <C, T, U, A>(left: Parser<C, T, A>, right: Parser<C, U, A>) -> Parser<C, U, A> {
	return left >>- const(right)
}

