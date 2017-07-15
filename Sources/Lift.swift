
public func lift<C, T, U, V>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V> {
	return .pure(curry(f))
}


