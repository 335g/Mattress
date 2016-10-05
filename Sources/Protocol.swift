//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - ParserProtocol

public protocol ParserProtocol {
	associatedtype Targets: Collection
	associatedtype Tree
	
	func parse<A>(_ targets: Targets, at index: Targets.Index, ifSuccess: (Tree, Targets.Index) -> A, ifFailure: (ParsingError<Targets.Index>) -> A) -> A
}

