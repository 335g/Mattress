
public struct ParsingError<C: Collection> {
	let reason: String
	let index: C.Index
	
	public init(at index: C.Index, becauseOf reason: String) {
		self.reason = reason
		self.index = index
	}
}

public struct Error<C: Collection>: Swift.Error {
	let error: ParsingError<C>
	
	init(_ error: ParsingError<C>) {
		self.error = error
	}
}
