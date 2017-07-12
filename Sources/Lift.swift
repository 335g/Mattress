
public func lift<C, T, U, V, A>(_ f: @escaping (T, U) -> V) -> Parser<C, (T) -> (U) -> V, A> {
	return .pure(curry(f))
}


