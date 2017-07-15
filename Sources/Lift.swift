
public func lift<C, T, U, V>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V> {
	return .pure(curry(f))
}

public func lift<C, T, U, V, W>(_ f: @escaping (T, U, V) -> W) -> Parser< C, (T) -> (U) -> (V) -> W> {
	return .pure(curry(f))
}
