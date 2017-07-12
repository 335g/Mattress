
import Runes

extension Parser {
	public func or(_ other: Parser<C, T, A>) -> Parser<C, T, A> {
		return Parser<C, T, A> { input, index, ifFailure, ifSuccess in
			try self.parser(input, index,
			               { _ in try other.parser(input, index, ifFailure, { t, i in try ifSuccess(t, i) }) },
			               { t, i in try ifSuccess(t, i) }
			)
		}
	}
}

public func <|> <C, T, A>(left: Parser<C, T, A>, right: Parser<C, T, A>) -> Parser<C, T, A> {
	return left.or(right)
}

extension Parser {
	public func maybe() -> Parser<C, T?, A> {
		return { $0.first } <^> self * (0...1)
	}
}

postfix operator |?
public postfix func |? <C, T, A>(parser: Parser<C, T, A>) -> Parser<C, T?, A> {
	return parser.maybe()
}

