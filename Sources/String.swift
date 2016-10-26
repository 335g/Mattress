//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


public prefix func % (literal: String) -> MapParser<CollectionParser<String.CharacterView>, String> {
	return MapParser(parser: CollectionParser(literal.characters, ==), mapping: String.init)
}

public func satisfy<C>(_ pred: @escaping (C.Iterator.Element) -> Bool) -> Parser<C> {
	return Parser(pred)
}

public func oneOf<C>(_ input: C) -> Parser<C> where C.Iterator.Element: Equatable {
	return satisfy { elem in
		input.contains(where: { $0 == elem })
	}
}

public func noneOf<C>(_ input: C) -> Parser<C> where C.Iterator.Element: Equatable {
	return satisfy { elem in
		!input.contains(where: { $0 == elem })
	}
}

public func char(_ x: Character) -> Parser<String.CharacterView> {
	return satisfy { $0 == x }
}

public prefix func % (literal: Character) -> Parser<String.CharacterView> {
	return char(literal)
}

