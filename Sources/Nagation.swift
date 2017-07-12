
extension Parser {
	public func isNot() -> Parser<C, (), A> {
		return Parser<C, () ,A> { input, index, ifFailure, ifSuccess in
			try self.parser(input, index,
			                { _ in try ifSuccess((), index) },
			                { input, index in try ifFailure(ParsingError(at: index, becauseOf: "Do not match '\(input)'")) }
			)
			
		}
	}
}
