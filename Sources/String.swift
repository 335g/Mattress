//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

public func char(_ x: Character) -> Parser<String.CharacterView> {
	return satisfy{ $0 == x }
}

public prefix func % (literal: Character) -> Parser<String.CharacterView> {
	return char(literal)
}

public prefix func % (literal: String) -> MapParser<CollectionParser<String.CharacterView>, String> {
	return MapParser(parser: CollectionParser(literal.characters), mapping: String.init)
}

public prefix func % (range: ClosedRange<String>) -> Parser<String.CharacterView> {
	return satisfy{ range.contains("\($0)") }
}

public prefix func % (range: Range<String>) -> MapParser<Parser<String.CharacterView>, String> {
	return MapParser(parser: satisfy{ range.contains("\($0)") }, mapping: { "\($0)" })
}

// MARK: - Default implemented parser

public let digit		= oneOf("0123456789".characters)
public let space		= char(" ")
public let comma		= char(",")
public let semicolon	= char(";")
public let colon		= char(":")
public let dot			= char(".")
public let backslash	= char("\\")
public let equals		= char("=")

public let cr			= char("\r")
public let crlf			= char("\r\n")
public let newline		= char("\n")
public let tab			= char("\t")
public let endOfLine	= newline <|> crlf

public let lparen		= char("(")
public let rparen		= char(")")
public let lbracket		= char("[")
public let rbracket		= char("]")
public let langle		= char("<")
public let rangle		= char(">")
public let lbrace		= char("{")
public let rbrace		= char("}")