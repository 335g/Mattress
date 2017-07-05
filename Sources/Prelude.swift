
func const<T, U>(_ x: T) -> (U) -> T {
	return { _ in x }
}

func id<T>(_ x: T) -> T {
	return x
}

func curry<T, U, V>(_ f: @escaping (T, U) -> V) -> (T) -> (U) -> V {
	return { x in { f(x, $0) } }
}
