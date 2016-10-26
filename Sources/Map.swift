//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude
import Either

// MARK: - MapParser

public struct MapParser<P, T>: ParserProtocol where
	P: ParserProtocol
{
	private let parser: P
	private let mapping: (P.Tree) -> T
	
	public init(parser: P, mapping: @escaping (P.Tree) -> T) {
		self.parser = parser
		self.mapping = mapping
	}
	
	// MARK: ParserProtocol
	
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

// MARK: - Operator

extension ParserProtocol {
	public static func <^> <T>(f: @escaping (Self.Tree) -> T, parser: Self) -> MapParser<Self, T> {
		return MapParser(parser: parser, mapping: f)
	}
	
	public static func <^ <T>(value: T, parser: Self) -> MapParser<Self, T> {
		return const(value) <^> parser
	}
}
