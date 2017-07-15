
public struct ParsingError<C: Collection>: Error {
	public let reason: String
	public let index: C.Index
	
	public init(at index: C.Index, becauseOf reason: String) {
		self.reason = reason
		self.index = index
	}
}
