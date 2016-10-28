//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Either

// MARK: - ParserProtocol

public protocol ParserProtocol {
	associatedtype Targets: Collection
	associatedtype Tree
	
	func parse<A>(_ input: Targets, at index: Targets.Index, ifSuccess: (Tree, Targets.Index) throws -> A) throws -> A
}

extension ParserProtocol {
	public func parse(_ input: Targets) throws -> Tree {
		return try parse(input, at: input.startIndex, ifSuccess: { tree, index in
			guard index == input.endIndex else {
				throw ParsingError.notEnd(index)
			}
			
			return tree
		})
	}
}
