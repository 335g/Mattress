
import Runes

public func <|> <C, T, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, T, A>.Function) -> Parser<C, T, A>.Function {
	return { input, index, ifFailure, ifSuccess in
		return try left(input, index,
		                { _ in try right(input, index, ifFailure, { t, i in try ifSuccess(t, i) }) },
		                { t, i in try ifSuccess(t, i) }
		)
	}
}

postfix operator |?
public postfix func |? <C, T, A>(parser: @escaping Parser<C, T, A>.Function) -> Parser<C, T?, A>.Function {
	return { $0.first } <^> parser * (0...1)
}
