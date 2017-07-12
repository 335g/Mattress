
import Runes
import Mattress

indirect enum Lambda: CustomStringConvertible {
	case variable(String)
	case abstraction(String, Lambda)
	case application(Lambda, Lambda)
	
	var description: String {
		switch self {
		case .variable(let symbol):
			return symbol
		case .abstraction(let symbol, let body):
			return "λ\(symbol).\(body.description)"
		case .application(let x, let y):
			return "(\(x.description) \(y.description))"
		}
	}
}

func fix<T1, T2, T3, T4, U>(_ f: @escaping (@escaping (T1, T2, T3, T4) throws -> U) -> (T1, T2, T3, T4) throws -> U) -> (T1, T2, T3, T4) throws -> U {
	return { try f(fix(f))($0, $1, $2, $3) }
}

func pair<T, U>(_ t: T, _ u: U) -> (T, U) {
	return (t, u)
}

typealias LambdaParser<T> = Parser<String.CharacterView, T, Lambda>.Function

let lambda: LambdaParser<Lambda> = fix { (lambda: @escaping LambdaParser<Lambda>) in
	let symbol: LambdaParser<String> = { String($0) } <^> %("a"..."z")
	
	let variable: LambdaParser<Lambda> = Lambda.variable <^> symbol
	let abstraction: LambdaParser<Lambda> = Lambda.abstraction <^> (lift(pair) <*> (%"λ" *> symbol) <*> (%"." *> lambda))
	let application: LambdaParser<Lambda> = Lambda.application <^> (lift(pair) <*> (%"(" *> lambda) <*> (%" " *> lambda) <* %")")
	return variable <|> abstraction <|> application
}

try? parse("λx.(x x)", with: lambda)
try? parse("λx.(x x) λx.(x x)", with: lambda)
