

public enum ParsingError<C: Collection> {
	case cast
	case notSatisfaction(C.Index)
	case notMatch(C.Index)
	case alreadyEnd(C.Index)
}

public struct Error<C: Collection>: Swift.Error {
	let error: ParsingError<C>
	
	init(_ error: ParsingError<C>) {
		self.error = error
	}
}
