
func const<T, U>(_ x: T) -> (U) -> T {
	return { _ in x }
}

func id<T>(_ x: T) -> T {
	return x
}

func curry<T, U, V>(_ f: @escaping (T, U) -> V) -> (T) -> (U) -> V {
	return { x in { f(x, $0) } }
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
