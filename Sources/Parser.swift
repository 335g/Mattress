//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - Parser

public struct Parser<C>: ParserProtocol where C: Collection {
	private let satisfy: (C.Iterator.Element) -> Bool
	
	public init(_ satisfy: @escaping (C.Iterator.Element) -> Bool) {
		self.satisfy = satisfy
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = C
	public typealias Tree = C.Iterator.Element
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C.Iterator.Element, C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		guard let nextIndex = input.index(index, offsetBy: 1, limitedBy: input.endIndex) else {
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
		
		let x = input[index]
		return satisfy(x)
			? ifSuccess(x, nextIndex)
			: ifFailure(ParsingError(index: index, reason: "not eq"))
	}
}

// MARK: - Constructor

public prefix func % <C>(literal: C.Iterator.Element) -> Parser<C> where C: Collection, C.Iterator.Element: Equatable {
	return Parser { $0 == literal }
}
