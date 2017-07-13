
import Runes

public typealias DoubleParser<A> = Parser<String.CharacterView, Double, A>
public typealias IntParser<A> = Parser<String.CharacterView, Int, A>

extension Parser where C == String.CharacterView {
	public static var digit: CharacterParser<A> {
		return oneOf("0123456789")
	}
	
	private static var someDigits: CharacterArrayParser<A> {
		return Parser.digit.some
	}
	
	private static var int: CharacterArrayParser<A> {
		return maybePrepend <^> Parser.char("-")|? <*> Parser.someDigits
	}
	
	private static var decimal: CharacterArrayParser<A> {
		return prepend <^> %"." <*> Parser.someDigits
	}
	
	private static var exp: StringParser<A> {
		return %"e+" <|> %"e-" <|> %"e" <|> %"E+" <|> %"E-" <|> %"E"
	}
	
	private static var exponent: CharacterArrayParser<A> {
		return { s in { s.characters + $0 }} <^> Parser.exp <*> Parser.someDigits
	}
	
	public static var number: DoubleParser<A> {
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
