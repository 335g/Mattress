//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - CollectionParser

public struct CollectionParser<C>: ParserProtocol where
	C: Collection,
	C.Iterator.Element: Equatable,
	C.SubSequence.Iterator.Element == C.Iterator.Element
{
	private let compared: C
	
	public init(_ x: C) {
		compared = x
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = C
	public typealias Tree = C
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C, C.Index) throws -> A) throws -> A {
		guard let lastIndex = input.index(index, offsetBy: compared.count, limitedBy: input.endIndex) else {
			throw ParsingError.rangeOver(index)
		}
		
		let allOk = zip(compared, input.suffix(from: index)).lazy.map{ $0 == $1 }.reduce(true){ $0 && $1 }
		guard allOk else {
			throw ParsingError.notEqual(index)
		}
			
		return try ifSuccess(compared, lastIndex)
	}
}

// MARK: - Constructor

public prefix func % <C>(literal: C) -> CollectionParser<C> {
	return CollectionParser(literal)
}
