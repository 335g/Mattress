
public func not<C, T>(_ parser: @escaping Parser<C, T>.Function) -> Parser<C, ()>.Function {
	return { input, index, ifFailure, ifSuccess in
		try parser(input, index,
		           { _ in try ifSuccess((), index) },
		           { _, index in try ifFailure(.doNotMatch(index)) }
		)
	}
}
