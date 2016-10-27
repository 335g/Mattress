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
	
	public func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: ([P.Tree], P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A) -> A {
		return parse(input, at: index, ifSuccess: ifSuccess, ifFailure: ifFailure, time: 0)
	}
	
	private func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: ([P.Tree], P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A, time: Int) -> A {
		
		switch time {
		case 0...0:
			return parser.parse(input, at: index,
				ifSuccess: { tree, index in
					return self.times.upperBound > 1
						? parse(input, at: index,
							ifSuccess: { treeCollection, index in
								var collection = treeCollection
								collection.insert(tree, at: 0)
								return ifSuccess(collection, index)
							},
							ifFailure: ifFailure,
							time: 1)
						: ifSuccess([tree], index)
									
				},
				ifFailure: { err in
				
					/// match the empty list if you allow the empty.
					return self.times.lowerBound == 0
						? pure([]).parse(input, at: index, ifSuccess: ifSuccess, ifFailure: ifFailure)
						: ifFailure(err)
				})
			
		case 1...times.upperBound:
			return parser.parse(input, at: index,
				ifSuccess: { tree, index in
					let nextTime = time == Int.max ? Int.max : time + 1
						return parse(input, at: index,
							ifSuccess: { treeCollection, index in
								ifSuccess([tree] + treeCollection, index)
							},
							ifFailure: ifFailure,
							time: nextTime)
				},
				ifFailure: { err in
					return time >= times.lowerBound
						? pure([]).parse(input, at: index, ifSuccess: ifSuccess, ifFailure: ifFailure)
						: ifFailure(err)
				})
			
		default:
			return ifFailure(ParsingError(index: index, reason: "range over"))
		}
	}
}

// MARK: - Constructor

public func many<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.many(parser)
}

public func some<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.some(parser)
}

public func * <P>(parser: P, range: ClosedRange<Int>) -> RepetitionParser<P> {
	return RepetitionParser.times(parser, times: range)
}

public func * <P>(parser: P, times: Int) -> RepetitionParser<P> {
	return RepetitionParser.times(parser, times: times)
}
