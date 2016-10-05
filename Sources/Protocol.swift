//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Either


// MARK: - ParserProtocol

public protocol ParserProtocol {
	associatedtype Targets: Collection
	associatedtype Tree
	
	func parse<A>(_ input: Targets, at index: Targets.Index, ifSuccess: (Tree, Targets.Index) -> A, ifFailure: (ParsingError<Targets.Index>) -> A) -> A
}

extension ParserProtocol {
	public func parse(_ input: Targets) -> Either<ParsingError<Targets.Index>, Tree> {
		return parse(input, at: input.startIndex,
			ifSuccess: { tree, index in
				return index == input.endIndex
					? Either.right(tree)
					: Either.left(ParsingError(index: index, reason: "not end"))
				},
			ifFailure: Either.left
		)
	}
}
