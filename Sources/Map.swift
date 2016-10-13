//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - MapParser

public struct MapParser<P, T> where P: ParserProtocol {
	fileprivate let parser: P
	fileprivate let mapping: (P.Tree) -> T
	
	public init(parser: P, mapping: @escaping (P.Tree) -> T) {
		self.parser = parser
		self.mapping = mapping
	}
}

// MARK: - MapParser : ParserProtocol

extension MapParser: ParserProtocol {
	public typealias Targets = P.Targets
	public typealias Tree = T
	
	public func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: (T, P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A) -> A {
		return parser.parse(input, at: index,
			ifSuccess: { tree, index in ifSuccess(mapping(tree), index) },
			ifFailure: ifFailure
		)
	}
}

// MARK: - Constructor

public func pure<C, T>(_ x: T) -> MapParser<AnyParser<C>, T> {
	return MapParser<AnyParser<C>, T>(parser: any(), mapping: const(x))
}

public prefix func % (literal: String) -> MapParser<CollectionParser<String.CharacterView>, String> {
	return MapParser(parser: CollectionParser(literal.characters), mapping: String.init)
}
