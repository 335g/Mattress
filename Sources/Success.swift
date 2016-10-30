//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - SuccessParser

public struct SuccessParser<C: Collection> {}

// MARK: - SuccessParser : ParserProtocol

extension SuccessParser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = ()
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: ((), C.Index) throws -> A) throws -> A {
		return try ifSuccess((), index)
	}
}

// MARK: - Constructor

public func success<C>() -> SuccessParser<C> {
	return SuccessParser()
}
