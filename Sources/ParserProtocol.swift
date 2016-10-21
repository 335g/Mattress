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
	
	public func mapped() -> MapParser<Self, Tree> {
		return MapParser(parser: self, mapping: id)
	}
}

// MARK: - Operator

extension ParserProtocol {
	public static func <^> <T>(f: @escaping (Self.Tree) -> T, parser: Self) -> MapParser<Self, T> {
		return MapParser(parser: parser, mapping: f)
	}
	
	public static func <^> <T>(f: @escaping (Self.Tree) -> T, parser: Self) -> ConcatParser<Self, MapParser<AnyParser<Self.Targets>, T>> {
		return parser >>- { pure(f($0)) }
	}
	
	public static func <^ <T>(value: T, parser: Self) -> MapParser<Self, T> {
		return const(value) <^> parser
	}
	
	public static func <^ <T>(value: T, parser: Self) -> ConcatParser<Self, MapParser<AnyParser<Self.Targets>, T>> {
		return const(value) <^> parser
	}
	
	public static func <|> <P>(this: Self, another: P) -> AltParser<Self, P> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return AltParser(this: this, another: another)
	}
	
	public static func >>- <P>(previous: Self, fn: @escaping (Self.Tree) -> P) -> ConcatParser<Self, P> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return ConcatParser(previous: previous, toBehind: fn)
	}
	
	public static func *> <P>(previous: Self, behind: P) -> ConcatParser<Self, P> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return ConcatParser(previous: previous, toBehind: const(behind))
	}
	
	public static func <* <P>(previous: Self, behind: P) -> IgnoreParser<Self, MapParser<P, Self.Tree>> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return IgnoreParser(previous: previous, toBehind: { const($0) <^> behind })
	}
	
	public static func <*> <T, P>(left: P, right: Self) -> ConcatParser<P, MapParser<Self, T>> where
		P: ParserProtocol,
		P.Targets == Self.Targets,
		P.Tree == (Self.Tree) -> T
	{
		return left >>- { $0 <^> right }
	}	
}

