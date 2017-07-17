
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

extension Parser {
	public func maybe() -> Parser<C, T?> {
		return { $0.first } <^> self * (0...1)
	}
}

postfix operator |?
public postfix func |? <C, T>(parser: Parser<C, T>) -> Parser<C, T?> {
	return parser.maybe()
}

