//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


// MARK: - RepetitionParser

public struct RepetitionParser<P> where P: ParserProtocol {
	fileprivate let parser: P
	fileprivate let times: ClosedRange<Int>
	
	private init(parser: P, times: ClosedRange<Int>) {
		self.parser = parser
		self.times = times
	}
	
	public static func many(_ parser: P, times: Int = Int.max) -> RepetitionParser {
		precondition(times >= 0, "You should use a value greater than or equal to 0.")
		
		return RepetitionParser(parser: parser, times: 0...times)
	}
	
	public static func some(_ parser: P, times: Int = Int.max) -> RepetitionParser {
		precondition(times > 0, "You should use a value greater than 0.")
		
		return RepetitionParser(parser: parser, times: 1...times)
	}
	
	public static func times(_ parser: P, times: ClosedRange<Int>) -> RepetitionParser {
		return RepetitionParser(parser: parser, times: times)
	}
}

// MARK: - RepetitionParser : ParserProtocol

extension RepetitionParser: ParserProtocol {
	public typealias Targets = P.Targets
	public typealias Tree = [P.Tree]
	
	public func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: ([P.Tree], P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A) -> A {
		
		return parse(input, at: index, ifSuccess: ifSuccess, ifFailure: ifFailure, time: 1)
	}
	
	private func parse<A>(_ input: P.Targets, at index: P.Targets.Index, ifSuccess: ([P.Tree], P.Targets.Index) -> A, ifFailure: (ParsingError<P.Targets.Index>) -> A, time: Int) -> A {
		
		switch time {
		case self.times:
			return parser.parse(input, at: index,
				ifSuccess: { tree, index in
					let nextTime = time == Int.max ? Int.max : time + 1
					return self.parse(input, at: index,
						ifSuccess: { treeCollection, index in
							return ifSuccess([tree] + treeCollection, index)
						},
						ifFailure: ifFailure,
						time: nextTime
					)
				},
				ifFailure: { _ in
					return pure([]).parse(input, at: index,
						ifSuccess: ifSuccess,
						ifFailure: ifFailure
					)
				}
			)
		default:
			return pure([]).parse(input, at: index, ifSuccess: ifSuccess, ifFailure: ifFailure)
		}
	}
}
