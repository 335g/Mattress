//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude
import Either


// MARK: - ParserProtocol

public protocol ParserProtocol {
	associatedtype Targets: Collection
	associatedtype Tree
	
	func parse<A>(_ input: Targets, at index: Targets.Index, ifSuccess: (Tree, Targets.Index) -> A, ifFailure: (ParsingError<Targets.Index>) -> A) -> A
}

extension ParserProtocol {
	public func parse(_ input: Targets) -> Either<ParsingError<Targets.Index>, Tree> {
		return parse(input, at: input.startIndex,
			ifSuccess: { tree, index in
				return index == input.endIndex
					? Either.right(tree)
					: Either.left(ParsingError(index: index, reason: "not end"))
				},
			ifFailure: Either.left
		)
	}
}

// MARK: - Combinator

extension ParserProtocol {
	public static func <^> <T>(f: @escaping (Self.Tree) -> T, parser: Self) -> MapParser<Self, T> {
		return MapParser(parser: parser, mapping: f)
	}
	
	// Nothing better?
//	public static func <^> <T>(f: @escaping (Self.Tree) -> T, parser: Self) -> ConcatParser<Self, MapParser<AnyParser<Targets>, T>> {
//		return parser >>- { pure(f($0)) }
//	}
	
	public static func <^ <T>(value: T, parser: Self) -> MapParser<Self, T> {
		return const(value) <^> parser
	}
	
	public func flatMap<P>(_ fn: @escaping (Self.Tree) -> P) -> ConcatParser<Self, P> where P: ParserProtocol, P.Targets == Self.Targets {
		return ConcatParser(before: self, flatten: fn)
	}
	
	public static func >>- <P>(parser: Self, fn: @escaping (Self.Tree) -> P) -> ConcatParser<Self, P> where P: ParserProtocol, P.Targets == Self.Targets {
		return parser.flatMap(fn)
	}
}

public func <*> <T, P1, P2>(left: P1, right: P2) -> MapParser<P1, T> where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Tree == (P2.Tree) -> T
{
	fatalError()
}
