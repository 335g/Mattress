
extension Parser {
	public var isNot: Parser<C, ()> {
		return Parser<C, ()> { input, index, ifFailure, ifSuccess in
			try self.parse(input, at: index,
				ifFailure: { _ in try ifSuccess((), index) },
				ifSuccess: { input, index in try ifFailure(ParsingError(at: index, becauseOf: "Do not match '\(input)'")) }
			)
		}
	}
}

public func not<C, T>(_ parser: Parser<C, T>) -> Parser<C, ()> {
	return parser.isNot
}
