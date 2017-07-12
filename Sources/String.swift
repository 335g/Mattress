
import Runes

//public typealias StringParser<A> = Parser<String.CharacterView, String, A>.Function
//public typealias CharacterParser<A> = Parser<String.CharacterView, Character, A>.Function
//public typealias CharacterArrayParser<A> = Parser<String.CharacterView, [Character], A>.Function
//public typealias DoubleParser<A> = Parser<String.CharacterView, Double, A>.Function
//public typealias IntParser<A> = Parser<String.CharacterView, Int, A>.Function
//
//public func char<A>(_ x: Character) -> CharacterParser<A> {
//	return satisfy{ $0 == x }
//}
//
//public func tab<A>() -> CharacterParser<A> {
//	return char("\t")
//}
//
//public func space<A>() -> CharacterParser<A> {
//	return char(" ")
//}
//
//public func newLine<A>() -> CharacterParser<A> {
//	return char("\n")
//}
//
//public func cr<A>() -> CharacterParser<A> {
//	return char("\r")
//}
//
//public func crlf<A>() -> CharacterParser<A> {
//	return char("\r\n")
//}
//
//public func endOfLine<A>() -> CharacterParser<A> {
//	return newLine() <|> crlf()
//}
//
//public func oneOf<A>(_ input: String) -> CharacterParser<A> {
//	return satisfy{ input.characters.contains($0) }
//}
//
//public func noneOf<A>(_ input: String) -> CharacterParser<A> {
//	return satisfy{ !input.characters.contains($0) }
//}
//
//public func digit<A>() -> CharacterParser<A> {
//	return oneOf("0123456789")
//}
//
//private func someDigits<A>() -> CharacterArrayParser<A> {
//	return some(digit())
//}
//
//private func maybePrepend<T>(_ value: T?) -> ([T]) -> [T] {
//	guard let value = value else {
//		return { $0 }
//	}
//	
//	return prepend(value)
//}
//
//private func int<A>() -> CharacterArrayParser<A> {
//	return maybePrepend <^> char("-")|? <*> someDigits()
//}
//
//private func decimal<A>() -> CharacterArrayParser<A> {
//	return prepend <^> %"." <*> someDigits()
//}
//
//private func exp<A>() -> StringParser<A> {
//	return %"e+" <|> %"e-" <|> %"e" <|> %"E+" <|> %"E-" <|> %"E"
//}
//
//private func exponent<A>() -> CharacterArrayParser<A> {
//	return { s in { s.characters + $0 }} <^> exp() <*> someDigits()
//}
//
//private func concat<T>(_ x: [T]) -> ([T]) -> [T] {
//	return { x + $0 }
//}
//
//private func concat2<T>(_ x: [T]) -> ([T]) -> ([T]) -> [T] {
//	return { y in { x + y + $0 }}
//}
//
//public func number<A>() -> DoubleParser<A> {
//	let num: CharacterArrayParser<A> = (concat2 <^> int() <*> decimal() <*> exponent())
//		<|> (concat <^> int() <*> decimal())
//		<|> (concat <^> int() <*> exponent())
//		<|> int()
//	
//	return { Double(String($0))! } <^> num
//}

