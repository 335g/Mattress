
import Runes

public protocol Union {
	static func + (lhs: Self, rhs: Self) -> Self
}

extension String: Union {}
extension Array: Union {}

extension Parser where T: Union {
	static func + (lhs: Parser<C, T>, rhs: Parser<C, T>) -> Parser<C, T> {
		return lift(+) <*> lhs <*> rhs
	}
}
