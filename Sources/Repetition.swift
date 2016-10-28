//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - RepetitionParser

/// A parser that repeatedly match to (many/some) things.
///
///
public struct RepetitionParser<P: ParserProtocol>: ParserProtocol {
	private let parser: P
	private let times: ClosedRange<Int>
	
	private init(parser: P, times: ClosedRange<Int>) {
		self.parser = parser
		self.times = times
	}
	
	fileprivate static func many(_ parser: P) -> RepetitionParser {
		return RepetitionParser(parser: parser, times: 0...Int.max)
	}
	
	fileprivate static func some(_ parser: P) -> RepetitionParser {
		return RepetitionParser(parser: parser, times: 1...Int.max)
	}
	
	fileprivate static func times(_ parser: P, times: ClosedRange<Int>) -> RepetitionParser {
		precondition(times.lowerBound >= 0, "lowerBound (upperBound) should be over or equal to 0.")
		
		return RepetitionParser(parser: parser, times: times)
	}
	
	fileprivate static func times(_ parser: P, times: Int) -> RepetitionParser {
		precondition(times > 0, "times should be over 0.")
		
		return RepetitionParser(parser: parser, times: times...times)
	}
	
	// MARK: ParserProtocol
	
	public typealias Targets = P.Targets
	public typealias Tree = [P.Tree]
	
	public func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: ([P.Tree], P.Targets.Index) throws -> A) throws -> A {
		return try parse(input, at: index, nth: 1, ifSuccess: ifSuccess)
	}
	
	private func parse<A>(_ input: P.Targets, at index: P.Targets.Index, nth: Int, ifSuccess: ([P.Tree], P.Targets.Index) throws -> A) throws -> A {
		
		do {
			return try parser.parse(input, at: index, ifSuccess: { tree, index in
				if times.upperBound <= 1 {
					return try ifSuccess([tree], index)
					
				}else {
					let next = nth == Int.max ? Int.max : nth + 1
					
					return try parse(input, at: index, nth: next, ifSuccess: { treeCollection, index in
						var collection = treeCollection
						collection.insert(tree, at: 0)
					
						return try ifSuccess(collection, index)
					})
				}
			})
		
		} catch {
			/// If it does not matched
			
			switch nth {
			case 1...1:
				/// It may be empty array if lowerbound is 0. (ex) `many`, 0...2, etc...
				
				if times.lowerBound == 0 {
					return try pure([]).parse(input, at: index, ifSuccess: ifSuccess)
				}else {
					throw ParsingError.notAllowNoMatch(index)
				}
				
			case times.lowerBound...times.lowerBound:
				throw ParsingError.notAllowNoMatch(index)
				
			case times, times.lowerBound...(times.upperBound == Int.max ? Int.max : times.upperBound + 1):
				return try pure([]).parse(input, at: index, ifSuccess: ifSuccess)
				
			default:
				throw ParsingError.debug(index)
			}
		}
	}
}

// MARK: - Constructor

public func some<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.some(parser)
}

public func some<P1, P2>(_ parser: P1, endBy terminator: P2) -> RepetitionParser<IgnoreParser<P1, MapParser<P2, P1.Tree>>> where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	return some(parser <* terminator)
}

public func some<P1, P2>(_ parser: P1, separatedBy separator: P2)
	-> ConcatParser<MapParser<P1, ([P1.Tree]) -> [P1.Tree]>, MapParser<RepetitionParser<ConcatParser<P2, P1>>, [P1.Tree]>>
	where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	return prepend <^> parser <*> many(separator *> parser)
}

public func many<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.many(parser)
}

public func many<P1, P2>(_ parser: P1, endBy terminator: P2) -> RepetitionParser<IgnoreParser<P1, MapParser<P2, P1.Tree>>> where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	return many(parser <* terminator)
}

public func many<P1, P2>(_ parser: P1, separatedBy separator: P2)
	-> AltParser<ConcatParser<MapParser<P1, ([P1.Tree]) -> [P1.Tree]>, MapParser<RepetitionParser<ConcatParser<P2, P1>>, [P1.Tree]>>, MapParser<AnyParser<P1.Targets>, [P1.Tree]>>
	where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	return some(parser, separatedBy: separator) <|> pure([])
}

public func many<P1, P2>(_ parser: P1, until end: P2) -> IgnoreParser<RepetitionParser<P1>, MapParser<P2, [P1.Tree]>> where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P1.Targets == P2.Targets
{
	return many(parser) <* end
}

public func * <P>(parser: P, range: ClosedRange<Int>) -> RepetitionParser<P> {
	return RepetitionParser.times(parser, times: range)
}

public func * <P>(parser: P, times: Int) -> RepetitionParser<P> {
	return RepetitionParser.times(parser, times: times)
}

// MARK: - Private 

private func prepend<T>(_ value: T) -> ([T]) -> [T] {
	return { arr in
		var arr = arr
		arr.insert(value, at: 0)
		return arr
	}
}
