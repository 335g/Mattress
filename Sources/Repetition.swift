
import Runes

public func many<C, T, A>(_ parser: @escaping Parser<C, T, A>.Function) -> Parser<C, [T], A>.Function {
	return prepend <^> parser <*> delay{ many(parser) } <|> pure([])
}

public func some<C, T, A>(_ parser: @escaping Parser<C, T, A>.Function) -> Parser<C, [T], A>.Function {
	return prepend <^> parser <*> many(parser)
}

extension Int {
	public func times<C, T, A>(_ parser: @escaping Parser<C, T, A>.Function) -> Parser<C, [T], A>.Function {
		precondition(self >= 0)
		
		return self != 0
			? prepend <^> parser <*> delay{ (self - 1).times(parser) }
			: pure([])
	}
}

public func * <C, T, A>(parser: @escaping Parser<C, T, A>.Function, n: Int) -> Parser<C, [T], A>.Function {
	return n.times(parser)
}

public func * <C, T, A>(parser: @escaping Parser<C, T, A>.Function, interval: CountableClosedRange<Int>) -> Parser<C, [T], A>.Function {
	precondition(interval.upperBound >= 0)
	
	return interval.upperBound == 0
		? { _, index, _, ifSuccess in try ifSuccess([], index) }
		: (parser >>- { append($0) <^> (parser * decrement(range: interval)) })
			<|> { _, index, ifFailure, ifSuccess in
					return interval.lowerBound <= 0
						? try ifSuccess([], index)
						: try ifFailure(ParsingError(at: index, becauseOf: "At least one must be matched."))
				}
}

public func * <C, T, A>(parser: @escaping Parser<C, T, A>.Function, interval: CountableRange<Int>) -> Parser<C, [T], A>.Function {
	return interval.isEmpty
		? { _, index, ifFailure, _ in try ifFailure(ParsingError(at: index, becauseOf: "At least one must be matched.")) }
		: parser * (interval.lowerBound...decrement(interval.upperBound))
}

public func sepBy1<C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, separator: @escaping Parser<C, U, A>.Function) -> Parser<C, [T], A>.Function {
	return prepend <^> parser <*> many(separator *> parser)
}

public func sepBy<C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, separator: @escaping Parser<C, U, A>.Function) -> Parser<C, [T], A>.Function {
	return sepBy1(parser: parser, separator: separator) <|> pure([])
}

public func endBy1<C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, terminator: @escaping Parser<C, U, A>.Function) -> Parser<C, [T], A>.Function {
	return some(parser <* terminator)
}

public func endBy<C, T, U, A>(parser: @escaping Parser<C, T, A>.Function, terminator: @escaping Parser<C, U, A>.Function) -> Parser<C, [T], A>.Function {
	return many(parser <* terminator)
}

//

private func decrement(_ x: Int) -> Int {
	return x == Int.max ? Int.max : x - 1
}

private func decrement(range: CountableClosedRange<Int>) -> CountableClosedRange<Int> {
	return decrement(range.lowerBound)...decrement(range.upperBound)
}

