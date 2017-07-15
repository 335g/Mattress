
import Runes
import Mattress

func fix<T, U, V>(_ f: @escaping (@escaping (T, U) -> V) -> (T, U) -> V) -> (T, U) -> V {
	return { f(fix(f))($0, $1) }
}

let input = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]

typealias FibonacciParser = Parser<[Int], [Int]>

let fibonacci = fix { (fibonacci: @escaping (Int, Int) -> FibonacciParser) in
	{ x, y in
		let combined = %(x + y) >>- { xy in
			{ [xy] + $0 } <^> fibonacci(y, xy)
		}
		
		return combined <|> .pure([])
	}
}(0, 1)

let parsed = try? fibonacci.parse(input)
