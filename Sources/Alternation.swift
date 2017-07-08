
import Runes

public func <|> <C, T>(left: @escaping Parser<C, T>.Function, right: @escaping Parser<C, T>.Function) -> Parser<C, T>.Function {
	return { input, index, ifFailure, ifSuccess in
		return try left(input, index,
		                { _ in try right(input, index, ifFailure, { t, i in try ifSuccess(t, i) }) },
		                { t, i in try ifSuccess(t, i) }
		)
	}
}
