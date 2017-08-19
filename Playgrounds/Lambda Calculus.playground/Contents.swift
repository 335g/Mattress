
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

let lambda = fix { (lambda: @escaping () -> StringParser<Lambda>) in
	{
		let symbol = ("a"..."z")%
		let variable = Lambda.variable <^> symbol.string
		let abstraction = Lambda.abstraction <^> (lift(pair) <*> ("λ"% *> symbol.string) <*> ("."% *> delay{ lambda() }))
		let application = Lambda.application <^> (lift(pair)
			<*> (.lparen *> delay{ lambda() })
			<*> (.space *> delay{ lambda() }) <* .rparen)
		return variable <|> abstraction <|> application
	}
}()

try? lambda.parse("λx.(x x)")
try? lambda.parse("λx.(x x) λx.(x x)")

