//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


public prefix func % (literal: Character) -> Parser<String.CharacterView> {
	return satisfy{ $0 == literal }
}

public prefix func % (literal: String) -> MapParser<CollectionParser<String.CharacterView>, String> {
	return MapParser(parser: CollectionParser(literal.characters), mapping: String.init)
}

public func satisfy<C>(_ pred: @escaping (C.Iterator.Element) -> Bool) -> Parser<C> {
	return Parser(pred)
}

