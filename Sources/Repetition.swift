
import Runes

public func many<C, T>(_ parser: @escaping Parser<C, T>.Function) -> Parser<C, [T]>.Function {
	return prepend <^> parser <*> delay{ many(parser) } <|> pure([])
}

public func some<C, T>(_ parser: @escaping Parser<C, T>.Function) -> Parser<C, [T]>.Function {
	return prepend <^> parser <*> many(parser)
}

extension Int {
	public func times<C, T>(_ parser: @escaping Parser<C, T>.Function) -> Parser<C, [T]>.Function {
		precondition(self >= 0)
		
		return self != 0
			? prepend <^> parser <*> delay{ (self - 1).times(parser) }
			: pure([])
	}
}

public func * <C, T>(parser: @escaping Parser<C, T>.Function, n: Int) -> Parser<C, [T]>.Function {
	return n.times(parser)
}

public func * <C, T>(parser: @escaping Parser<C, T>.Function, interval: CountableClosedRange<Int>) -> Parser<C, [T]>.Function {
	precondition(interval.upperBound >= 0)
	
	return interval.upperBound == 0
		? { _, index, _, ifSuccess in try ifSuccess([], index) }
		: (parser >>- { append($0) <^> (parser * decrement(range: interval)) })
			<|> { _, index, ifFailure, ifSuccess in
					return interval.lowerBound <= 0
						? try ifSuccess([], index)
						: try ifFailure(.atLeast(index))
				}
}

public func * <C, T>(parser: @escaping Parser<C, T>.Function, interval: CountableRange<Int>) -> Parser<C, [T]>.Function {
	return interval.isEmpty
		? { _, index, ifFailure, _ in try ifFailure(.atLeast(index)) }
		: parser * (interval.lowerBound...decrement(interval.upperBound))
}

public func sepBy1<C, T, U>(parser: @escaping Parser<C, T>.Function, separator: @escaping Parser<C, U>.Function) -> Parser<C, [T]>.Function {
	return prepend <^> parser <*> many(separator *> parser)
}

public func sepBy<C, T, U>(parser: @escaping Parser<C, T>.Function, separator: @escaping Parser<C, U>.Function) -> Parser<C, [T]>.Function {
	return sepBy1(parser: parser, separator: separator) <|> pure([])
}

public func endBy1<C, T, U>(parser: @escaping Parser<C, T>.Function, terminator: @escaping Parser<C, U>.Function) -> Parser<C, [T]>.Function {
	return some(parser <* terminator)
}

public func endBy<C, T, U>(parser: @escaping Parser<C, T>.Function, terminator: @escaping Parser<C, U>.Function) -> Parser<C, [T]>.Function {
	return many(parser <* terminator)
}

// 

private func decrement(_ x: Int) -> Int {
	return x == Int.max ? Int.max : x - 1
}

private func decrement(range: CountableClosedRange<Int>) -> CountableClosedRange<Int> {
	return decrement(range.lowerBound)...decrement(range.upperBound)
}
