
public func not<C, T, A>(_ parser: @escaping Parser<C, T, A>.Function) -> Parser<C, (), A>.Function {
	return { input, index, ifFailure, ifSuccess in
		try parser(input, index,
		           { _ in try ifSuccess((), index) },
		           { input, index in try ifFailure(ParsingError(at: index, becauseOf: "Do not match '\(input)'")) }
		)
	}
}

