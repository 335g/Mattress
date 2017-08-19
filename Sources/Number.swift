
import Runes

extension Parser where C == String {
	public static var digit: StringParser<Character> {
		return oneOf("0123456789")
	}
	
	private static var someDigits: StringParser<[Character]> {
		return Parser.digit.some
	}
	
	private static var int: StringParser<[Character]> {
		return maybePrepend <^> StringParser<Character>.char("-")|? <*> Parser.someDigits
	}
	
	private static var decimal: StringParser<[Character]> {
		return prepend <^> "."% <*> Parser.someDigits
	}
	
	private static var exp: StringParser<String> {
		return "e+"% <|> "e-"% <|> "e"% <|> "E+"% <|> "E-"% <|> "E"%
	}
	
	private static var exponent: StringParser<[Character]> {
		return { s in { s.characters + $0 }} <^> Parser.exp <*> Parser.someDigits
	}
	
	public static var number: StringParser<Double> {
		let num = (concat2 <^> Parser.int <*> Parser.decimal <*> Parser.exponent)
			<|> (concat <^> Parser.int <*> Parser.decimal)
			<|> (concat <^> Parser.int <*> Parser.exponent)
			<|> Parser.int
		
		return { Double(String($0))! } <^> num
	}
}

private func maybePrepend<T>(_ value: T?) -> ([T]) -> [T] {
	guard let value = value else {
		return { $0 }
	}
	
	return prepend(value)
}

private func concat<T>(_ x: [T]) -> ([T]) -> [T] {
	return { x + $0 }
}

private func concat2<T>(_ x: [T]) -> ([T]) -> ([T]) -> [T] {
	return { y in { x + y + $0 }}
}
