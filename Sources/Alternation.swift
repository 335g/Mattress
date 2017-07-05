
import Runes

public func <|> <C, T, A>(left: @escaping Parser<C, T, A>.Function, right: @escaping Parser<C, T, A>.Function) rethrows -> Parser<C, T, A>.Function where C.Element: Equatable {
	return { input, index, ifSuccess, ifFailure in
		try left(input, index, { t, i in try ifSuccess(t, i) }){ e in
			try right(input, index, { t, i in try ifSuccess(t, i) }, ifFailure)
		}
	}
}
