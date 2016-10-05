//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - MapParser

public struct MapParser<P, T> where P: ParserProtocol {
	let parser: P
	let mapping: (P.Tree) -> T
}

// MARK: - MapParser : ParserProtocol

extension MapParser: ParserProtocol {
	public typealias Targets = P.Targets
	public typealias Tree = T
	
	public func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: (T, P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A) -> A {
		return parser.parse(input, at: index,
			ifSuccess: { tree, index in ifSuccess(mapping(tree), index) },
			ifFailure: ifFailure
		)
	}
}
