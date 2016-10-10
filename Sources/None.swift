//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - NoneParser

public struct NoneParser<C: Collection> {}

// MARK: - NoneParser : ParserProtocol

extension NoneParser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = ()
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: ((), C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		return ifFailure(ParsingError(index: index, reason: "is none"))
	}
}
