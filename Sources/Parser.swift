

public enum Parser<C, T, A> where C: Collection {
	public typealias IfSuccess = (T, C.Index) throws -> A
	public typealias IfFailure = (ParsingError<C>) throws -> A	// always throw error
	public typealias Function = (C, C.Index, IfSuccess, IfFailure) throws -> A
}

func token<C, A>(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index) -> Parser<C, C.Element, A>.Function where C.Element: Equatable {
	
	return { input, index, ifSuccess, ifFailure in
		if index == input.endIndex {
			return try ifFailure(.end(index))
		}else {
			let elem = input[index]
			
			return pred(elem)
				? try ifSuccess(elem, next(input, index, elem))
				: try ifFailure(.end(index))
		}
	}
}

public func satisfy<C, A>(pred: @escaping (C.Element) -> Bool) -> Parser<C, C.Element, A>.Function where C.Element: Equatable {
	return token(pred){ input, index, elem in
		input.index(after: index)
	}
}

extension String {
	func contains(_ needle: String, at i: Index) -> Bool {
		guard let to = self.index(i, offsetBy: needle.count, limitedBy: self.endIndex) else {
			return false
		}
		
		return self[i..<to] == needle
	}
}

func contains<C1, C2>(_ needle: C1, at i: C2.Index, from collection: C2) -> Bool where
	C1: Collection,
	C2: Collection,
	C2.SubSequence: ToCluster,
	C2.SubSequence.Cluster == C1,
	C2.IndexDistance == C1.IndexDistance,
	C1: Equatable
{
	guard let to = collection.index(i, offsetBy: needle.count, limitedBy: collection.endIndex) else {
		return false
	}
	
	return collection[i..<to].toCluster() == needle
}

prefix operator %
public prefix func %<A>(literal: String) -> Parser<String, String, A>.Function {
	return { input, index, ifSuccess, ifFailure in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

public prefix func %<C, A>(literal: C) -> Parser<C, C, A>.Function where C: Equatable, C.SubSequence: ToCluster, C.SubSequence.Cluster == C {
	return { input, index, ifSuccess, ifFailure in
		return contains(literal, at: index, from: input)
			? try ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

public func none<C, T, A>() -> Parser<C, T, A>.Function {
	return { _, index, _, ifFailure in
		return try ifFailure(.notMatch(index))
	}
}

public func parse<C, T>(_ parser: Parser<C, T, T>.Function, input: C) rethrows -> T where C.Element: Equatable {
	let ifFailure: Parser<C, T, T>.IfFailure = { e in throw Error(e) }
	let ifSuccess: Parser<C, T, T>.IfSuccess = { a, _ in a }
	
	return try parser(input, input.startIndex, ifSuccess, ifFailure)
}


