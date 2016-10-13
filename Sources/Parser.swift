//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - Parser

public struct Parser<C> where C: Collection, C.Iterator.Element: Equatable {
	fileprivate let compared: C.Iterator.Element
	
	public init(_ x: C.Iterator.Element) {
		compared = x
	}
}

// MARK: - Parser : ParserProtocol

extension Parser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = C.Iterator.Element
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C.Iterator.Element, C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		guard let nextIndex = input.index(index, offsetBy: 1, limitedBy: input.endIndex) else {
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
		
		return input[index] == compared
			? ifSuccess(compared, nextIndex)
			: ifFailure(ParsingError(index: index, reason: "not eq"))
	}
}

// MARK: - Constructor

public prefix func % <C>(literal: C.Iterator.Element) -> Parser<C> {
	return Parser(literal)
}
