
func const<T, U>(_ x: T) -> (U) -> T {
	return { _ in x }
}

func id<T>(_ x: T) -> T {
	return x
}

func curry<T, U, V>(_ f: @escaping (T, U) -> V) -> (T) -> (U) -> V {
	return { x in { f(x, $0) } }
}

func curry<T, U, V, W>(_ f: @escaping (T, U, V) -> W) -> (T) -> (U) -> (V) -> W {
	return { x in { y in { f(x, y, $0) }}}
}

public func pair<A, B>(_ a: A, _ b: B) -> (A, B) {
	return (a, b)
}

public func triple<A, B, C>(_ a: A, _ b: B, _ c: C) -> (A, B, C) {
	return (a, b, c)
}

func prepend<T>(_ value: T) -> ([T]) -> [T] {
	return { arr in
		var arr = arr
		arr.insert(value, at: 0)
		return arr
	}
}

func append<T>(_ value: T) -> ([T]) -> [T] {
	return { arr in
		var arr = arr
		arr.append(value)
		return arr
	}
}
