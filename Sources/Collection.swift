//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - CollectionParser

public struct CollectionParser<C>: ParserProtocol where C: Collection, C.SubSequence.Iterator.Element == C.Iterator.Element {
	private let compared: C
	private let eq: (C.Iterator.Element, C.Iterator.Element) -> Bool
	
	public init(_ x: C, _ f: @escaping (C.Iterator.Element, C.Iterator.Element) -> Bool) {
		compared = x
		eq = f
	}
	
	// MARK: - ParserProtocol
	
	public typealias Targets = C
	public typealias Tree = C
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C, C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		guard let lastIndex = input.index(index, offsetBy: compared.count, limitedBy: input.endIndex) else {
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
		
		return zip(compared, input.suffix(from: index)).lazy.map(eq).reduce(true){ $0 && $1 }
			? ifSuccess(compared, lastIndex)
			: ifFailure(ParsingError(index: index, reason: "not eq"))
	}
}

// MARK: - Constructor

public prefix func % <C>(literal: C) -> CollectionParser<C> where C.Iterator.Element: Equatable {
	return CollectionParser(literal, ==)
}
