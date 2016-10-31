//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Either
import Prelude

// MARK: - AltParser

public struct AltParser<P1, P2>: ParserProtocol where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	private let this: P1
	private let another: P2
	
	fileprivate init(this: P1, another: P2) {
		self.this = this
		self.another = another
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = P1.Targets
	public typealias Tree = Either<P1.Tree, P2.Tree>
	
	public func parse<A>(_ input: P1.Targets, at index: P1.Targets.Index, ifSuccess: (Either<P1.Tree, P2.Tree>, P1.Targets.Index) throws -> A) throws -> A {
		
		do {
			return try this.parse(input, at: index, ifSuccess: { tree, index in try ifSuccess(.left(tree), index) })
			
		} catch ParsingError<Targets.Index>.notEnd(let index) {
			/// short circuiting
			throw ParsingError<Targets.Index>.notEnd(index)
			
		} catch {
			return try self.another.parse(input, at: index, ifSuccess: { tree, index in try ifSuccess(Either.right(tree), index) })
		}
	}
}

extension AltParser where P1.Tree == P2.Tree {
	public func extract() -> MapParser<AltParser, P1.Tree> {
		return MapParser(
			parser: self,
			mapping: { $0.either(ifLeft: id, ifRight: id) }
		)
	}
}

// MARK: - Operator

extension ParserProtocol {
	public static func <|> <P>(this: Self, another: P) -> AltParser<Self, P>
		where
			P: ParserProtocol,
			P.Targets == Self.Targets
	{
		return AltParser(this: this, another: another)
	}
	
	public static func <|> <P>(this: Self, another: P) -> MapParser<AltParser<Self, P>, Self.Tree>
		where
			P: ParserProtocol,
			P.Targets == Self.Targets,
			P.Tree == Self.Tree
	{
		return AltParser(this: this, another: another).extract()
	}
}
