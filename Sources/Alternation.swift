
import Runes

extension Parser {
	public mutating func consume() {
		self.consumeType = true
	}
	
	public func or(_ other: Parser<C, T>) -> Parser<C, T> {
		return Parser<C, T> { input, index, ifFailure, ifSuccess in
			try self.parse(input, at: index,
				ifFailure: { err in
					let i2 = self.consumeType ? err.index : index
					return try other.parse(input, at: i2, ifFailure: ifFailure, ifSuccess: { t, i in try ifSuccess(t, i) })
				},
				ifSuccess: { t, i in try ifSuccess(t, i) }
			)
		}
	}
}



public func <|> <C, T>(left: Parser<C, T>, right: Parser<C, T>) -> Parser<C, T> {
	return left.or(right)
}

public func oneOf<C, S>(_ seq: S) -> Parser<C, C.Element> where S: Sequence, S.Element == C.Element, C.Element: Equatable {
	return .satisfy{ seq.contains($0) }
}

// maybe

extension Parser {
	public func maybe() -> Parser<C, T?> {
		return { $0.first } <^> self * (0...1)
	}
}

postfix operator |?
public postfix func |? <C, T>(parser: Parser<C, T>) -> Parser<C, T?> {
	return parser.maybe()
}

// to take parentheses

postfix operator %?
public postfix func %? <C>(literal: C) -> Parser<C, C?> where C.Element: Equatable {
	return literal%.maybe()
}

public postfix func %? <C>(literal: C.Element) -> Parser<C, C.Element?> where C.Element: Equatable {
	return literal%.maybe()
}

public postfix func %? (literal: Substring) -> StringParser<String?> {
	return literal%.maybe()
}

public postfix func %? <C>(interval: ClosedRange<C.Element>) -> Parser<C, C.Element?> {
	return interval%.maybe()
}

public postfix func %?(interval: ClosedRange<Character>) -> StringParser<Character?> {
	return interval%.maybe()
}
