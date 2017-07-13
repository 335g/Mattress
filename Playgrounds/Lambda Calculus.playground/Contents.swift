
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

func fix<T>(_ f: @escaping (@escaping () -> T) -> () -> T) -> () -> T {
	return { f(fix(f))() }
}

func pair<T, U>(_ t: T, _ u: U) -> (T, U) {
	return (t, u)
}

typealias LambdaParser<T> = Parser<String.CharacterView, T, Lambda>

let lambda: LambdaParser<Lambda> = fix { (lambda: @escaping () -> LambdaParser<Lambda>) in
	{
		let symbol: LambdaParser<String> = { String($0) } <^> %("a"..."z")
		let variable = Lambda.variable <^> symbol
		let abstraction = Lambda.abstraction <^> (lift(pair) <*> (%"λ" *> symbol) <*> (%"." *> delay{ lambda() }))
		let application = Lambda.application <^> (lift(pair) <*> (%"(" *> delay{ lambda() }) <*> (%" " *> delay{ lambda() }) <* %")")
		return variable <|> abstraction <|> application
	}
}()

try? lambda.parse("λx.(x x)")
try? lambda.parse("λx.(x x) λx.(x x)")

