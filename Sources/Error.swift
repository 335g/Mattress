

public enum ParsingError<C: Collection> {
	case cast
	case notMatch(C.Index)
	case end(C.Index)
}

public struct Error<C: Collection>: Swift.Error {
	let error: ParsingError<C>
	
	init(_ error: ParsingError<C>) {
		self.error = error
	}
}
