
extension Parser {
	public func isNot() -> Parser<C, ()> {
		return Parser<C, ()> { input, index, ifFailure, ifSuccess in
			try self.parse(input, at: index,
			               ifFailure: { _ in try ifSuccess((), index) },
			               ifSuccess: { input, index in try ifFailure(ParsingError(at: index, becauseOf: "Do not match '\(input)'")) }
			)
		}
	}
}
