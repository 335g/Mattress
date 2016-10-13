//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - CollectionParser

public struct CollectionParser<C> where C: Collection, C.Iterator.Element: Equatable, C.SubSequence.Iterator.Element == C.Iterator.Element {
	fileprivate let compared: C
	
	public init(_ x: C) {
		compared = x
	}
}

// MARK: - Parser : ParserProtocol

extension CollectionParser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = C
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C, C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		guard let lastIndex = input.index(index, offsetBy: compared.count, limitedBy: input.endIndex) else {
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
		
		return zip(compared, input.suffix(from: index)).lazy.map{ $0 == $1 }.reduce(true){ $0 && $1 }
			? ifSuccess(compared, lastIndex)
			: ifFailure(ParsingError(index: index, reason: "not eq"))
	}
}

// MARK: - Constructor

public prefix func % <C>(literal: C) -> CollectionParser<C> {
	return CollectionParser(literal)
}
