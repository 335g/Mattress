//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - FailureParser

public struct FailureParser<C: Collection> {}

// MARK: - FailureParser : ParserProtocol

extension FailureParser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = ()
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: ((), C.Index) throws -> A) throws -> A {
		throw ParsingError.noReason(index)
	}
}

// MARK: - Constructor

public func failure<C>() -> FailureParser<C> {
	return FailureParser()
}
