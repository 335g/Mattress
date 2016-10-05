//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - Parser

public struct Parser<C> where C: Collection, C.Iterator.Element: Equatable {
	let compared: C
	
	public init(_ x: C) {
		compared = x
	}
}

// MARK: - Parser : ParserProtocol

extension Parser: ParserProtocol {
	public typealias Targets = C
	public typealias Tree = C
	
	public func parse<A>(_ input: C, at index: C.Index, ifSuccess: (C, C.Index) -> A, ifFailure: (ParsingError<C.Index>) -> A) -> A {
		guard let _ = input.index(index, offsetBy: compared.count, limitedBy: input.endIndex) else {
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
		
		var index = index
		for elem in compared {
			if input[index] != elem {
				return ifFailure(ParsingError(index: index, reason: "not eq"))
			}
			
			input.formIndex(after: &index)
		}
		
		return ifSuccess(input, index)
	}
}

