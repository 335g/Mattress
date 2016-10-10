//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

import Prelude


public prefix func % <C>(x: C) -> CollectionParser<C> {
	return CollectionParser(x)
}

public prefix func % (string: String) -> CollectionParser<String.CharacterView> {
	return CollectionParser(string.characters)
}

public func any<C>() -> AnyParser<C> where C: Collection {
	return AnyParser()
}

public func none<C>() -> NoneParser<C> where C: Collection {
	return NoneParser()
}

public func pure<C, T>(_ x: T) -> MapParser<AnyParser<C>, T> where C: Collection {
	return MapParser<AnyParser<C>, T>(parser: any(), mapping: const(x))
}

private func prepend<T>(_ x: T) -> ([T]) -> [T] {
	return { [x] + $0 }
}

public func many<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.many(parser)
}

public func some<P>(_ parser: P) -> RepetitionParser<P> {
	return RepetitionParser.some(parser)
}

public func * <P>(parser: P, range: ClosedRange<Int>) -> RepetitionParser<P> {
	return RepetitionParser.times(parser, times: range)
}
