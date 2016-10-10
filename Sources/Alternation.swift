//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Either


// MARK: - AltParser

public struct AltParser<P1, P2> where P1: ParserProtocol, P2: ParserProtocol, P1.Targets == P2.Targets {
	fileprivate let this: P1
	fileprivate let another: P2
	
	public init(this: P1, another: P2) {
		self.this = this
		self.another = another
	}
}

// AltParser : ParserProtocol

extension AltParser: ParserProtocol {
	public typealias Targets = P1.Targets
	public typealias Tree = Either<P1.Tree, P2.Tree>
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (Either<P1.Tree, P2.Tree>, P1.Targets.Index) -> A, ifFailure: (ParsingError<P1.Targets.Index>) -> A) -> A {
		return this.parse(input, at: index,
			ifSuccess: { tree, index in ifSuccess(Either.left(tree), index) },
			ifFailure: { _ in
				return self.another.parse(input, at: index,
					ifSuccess: { tree, index in ifSuccess(Either.right(tree), index) },
					ifFailure: ifFailure
				)
			}
		)
	}
}
