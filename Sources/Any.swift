//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - AnyParser

public struct AnyParser<C: Collection> {}

// MARK: - AnyParser : ParserProtocol

extension AnyParser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = ()
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: ((), C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		return ifSuccess((), index)
	}
}
