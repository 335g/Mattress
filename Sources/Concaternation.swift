//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude
import Either

// MARK: - ConcatParser

public struct ConcatParser<P1, P2>: ParserProtocol where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	private let previous: P1
	private let toBehind: (P1.Tree) -> P2
	
	fileprivate init(previous: P1, toBehind: @escaping (P1.Tree) -> P2) {
		self.previous = previous
		self.toBehind = toBehind
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = P1.Targets
	public typealias Tree = P2.Tree
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (P2.Tree, P1.Targets.Index) throws -> A) throws -> A {
		return try previous.parse(input, at: index, ifSuccess: { tree, index in
			try self.toBehind(tree).parse(input, at: index, ifSuccess: ifSuccess)
		})
	}
}

// MARK: - Operator

extension ParserProtocol {
	public static func >>- <P>(previous: Self, fn: @escaping (Self.Tree) -> P) -> ConcatParser<Self, P> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return ConcatParser(previous: previous, toBehind: fn)
	}
	
	public static func <*> <T, P>(left: P, right: Self) -> ConcatParser<P, MapParser<Self, T>> where
		P: ParserProtocol,
		P.Targets == Self.Targets,
		P.Tree == (Self.Tree) -> T
	{
		return left >>- { $0 <^> right }
	}
	
	public static func *> <P>(previous: Self, behind: P) -> ConcatParser<Self, P> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return ConcatParser(previous: previous, toBehind: const(behind))
	}
}

// MARK: - IgnoreParser

public struct IgnoreParser<P1, P2>: ParserProtocol where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	private let previous: P1
	private let toBehind: (P1.Tree) -> P2
	
	fileprivate init(previous: P1, toBehind: @escaping (P1.Tree) -> P2) {
		self.previous = previous
		self.toBehind = toBehind
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = P1.Targets
	public typealias Tree = P1.Tree
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (P1.Tree, P1.Targets.Index) throws -> A) throws -> A {
		return try previous.parse(input, at: index, ifSuccess: { tree, index in
			try self.toBehind(tree).parse(input, at: index, ifSuccess: { _, index in try ifSuccess(tree, index) })
		})
	}
}

// MARK: - Operator

extension ParserProtocol {
	public static func <* <P>(previous: Self, behind: P) -> IgnoreParser<Self, MapParser<P, Self.Tree>> where
		P: ParserProtocol,
		P.Targets == Self.Targets
	{
		return IgnoreParser(previous: previous, toBehind: { const($0) <^> behind })
	}
}
