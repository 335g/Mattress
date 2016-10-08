//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - ConcatParser

public struct ConcatParser<P1, P2> where P1: ParserProtocol, P2: ParserProtocol, P1.Targets == P2.Targets {
	let previous: P1
	let toBehind: (P1.Tree) -> P2
}

// MARK: - ConcatParser : ParserProtocol

extension ConcatParser: ParserProtocol {
	public typealias Targets = P1.Targets
	public typealias Tree = P2.Tree
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (P2.Tree, P1.Targets.Index) -> A, ifFailure: (ParsingError<P1.Targets.Index>) -> A) -> A {
		return previous.parse(input, at: index,
			ifSuccess: { tree, index in
				return self.toBehind(tree).parse(input, at: index,
					ifSuccess: ifSuccess,
					ifFailure: ifFailure
				)
			},
			ifFailure: ifFailure
		)
	}
}


// MARK: - IgnoreParser

public struct IgnoreParser<P1, P2> where P1: ParserProtocol, P2: ParserProtocol, P1.Targets == P2.Targets {
	let previous: P1
	let toBehind: (P1.Tree) -> P2
}

// MARK: - IgnoreParser : ParserProtocol

extension IgnoreParser: ParserProtocol {
	public typealias Targets = P1.Targets
	public typealias Tree = P1.Tree
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (P1.Tree, P1.Targets.Index) -> A, ifFailure: (ParsingError<P1.Targets.Index>) -> A) -> A {
		return previous.parse(input, at: index,
			ifSuccess: { tree, index in
				return self.toBehind(tree).parse(input, at: index,
					ifSuccess: { _, index in ifSuccess(tree, index) },
					ifFailure: ifFailure
				)
			},
			ifFailure: ifFailure
		)
	}
}
