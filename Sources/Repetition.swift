
import Runes

extension Parser {
	public var many: Parser<C, [T]> {
		return prepend <^> self <*> delay{ self.many } <|> .pure([])
	}
	
	public var some: Parser<C, [T]> {
		return prepend <^> self <*> self.many
	}
}

public func many<C, T>(_ parser: Parser<C, T>) -> Parser<C, [T]> {
	return parser.many
}

public func some<C, T>(_ parser: Parser<C, T>) -> Parser<C, [T]> {
	return parser.some
}

extension Int {
	public func times<C, T>(_ parser: Parser<C, T>) -> Parser<C, [T]> {
		precondition(self >= 0)
		
		return self != 0
			? prepend <^> parser <*> delay{ (self - 1).times(parser) }
			: .pure([])
	}
	
	func decrement() -> Int {
		return self == Int.max
			? Int.max
			: self - 1
	}
}

public func * <C, T>(parser: Parser<C, T>, n: Int) -> Parser<C, [T]> {
	return n.times(parser)
}

// TODO: Test for ContableClosedRange/CountableRange

extension CountableClosedRange where Bound == Int {
	private func decrement() -> CountableClosedRange {
		return CountableClosedRange(uncheckedBounds: (lowerBound.decrement(), upperBound.decrement()))
	}
	
	public func times<C, T>(_ parser: Parser<C, T>) -> Parser<C, [T]> {
		precondition(upperBound >= 0)
		
		return upperBound == 0
			? Parser<C, [T]>{ _, index, _, ifSuccess in try ifSuccess([], index) }
			: (parser >>- { append($0) <^> (self.decrement().times(parser)) })
				<|> Parser<C, [T]> { _, index, ifFailure, ifSuccess in
					return self.lowerBound <= 0
						? try ifSuccess([], index)
						: try ifFailure(ParsingError(at: index, becauseOf: "At least one must be matched."))
				}
	}
}

public func * <C, T>(parser: Parser<C, T>, interval: CountableClosedRange<Int>) -> Parser<C, [T]> {
	return interval.times(parser)
}

extension CountableRange where Bound == Int {
	private func decrement() -> CountableRange {
		return CountableRange(uncheckedBounds: (lowerBound.decrement(), upperBound.decrement()))
	}
	
	public func times<C, T>(_ parser: Parser<C, T>) -> Parser<C, [T]> {
		precondition(upperBound >= 0)
		
		return upperBound == 0
			? Parser<C, [T]> { _, index, _, ifSuccess in try ifSuccess([], index) }
			: (parser >>- { append($0) <^> (self.decrement().times(parser)) })
				<|> Parser<C, [T]> { _, index, ifFailure, ifSuccess in
					return self.lowerBound <= 0
						? try ifSuccess([], index)
						: try ifFailure(ParsingError(at: index, becauseOf: "At least one must be matched."))
				}
	}
}

public func * <C, T>(parser: Parser<C, T>, interval: CountableRange<Int>) -> Parser<C, [T]> {
	return interval.times(parser)
}

// MARK: - sep, end

extension Parser {
	public func isSeparatedByAtLeastOne<U>(by separator: Parser<C, U>) -> Parser<C, [T]> {
		return prepend <^> self <*> (separator *> self).many
	}
	
	public func isSeparated<U>(by separator: Parser<C, U>) -> Parser<C, [T]> {
		return self.isSeparatedByAtLeastOne(by: separator) <|> .pure([])
	}
	
	public func isTerminatedByAtLeastOne<U>(by terminator: Parser<C, U>) -> Parser<C, [T]> {
		return (self <* terminator).some
	}
	
	public func isTerminated<U>(by terminator: Parser<C, U>) -> Parser<C, [T]> {
		return (self <* terminator).many
	}
}

