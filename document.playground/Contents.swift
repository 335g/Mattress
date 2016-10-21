
import Prelude
import Either
import Mattress

func fibonacci<P>() -> (Int, Int) -> P where P: ParserProtocol, P.Targets == [Int], P.Tree == [Int] {
	return fix { fibo in
		{ (x: Int, y: Int) -> P in
			let parser: Parser<[Int]> = %(x + y)
			let combined: P = parser >>- { xy in
				let f: [Int] -> [Int] = { [xy] + $0 }
				return f <^> fibo(y, xy)
			}
			
			return combined <|> pure([])
		}
	}
}

