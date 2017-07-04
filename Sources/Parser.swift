

public enum Parser<C, T> where C: Collection {
	public typealias IfSuccess = (T, C.Index) -> T
	public typealias IfFailure = (ParsingError<C>) throws -> T
	public typealias Function = (C, C.Index, IfSuccess, IfFailure) throws -> T
}

func token<C>(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index) -> Parser<C, C.Element>.Function where C.Element: Equatable {
	
	return { input, index, ifSuccess, ifFailure in
		if index == input.endIndex {
			return try ifFailure(.end(index))
		}else {
			let elem = input[index]
			
			return pred(elem)
				? ifSuccess(elem, next(input, index, elem))
				: try ifFailure(.end(index))
		}
	}
}

public func satisfy<C>(pred: @escaping (C.Element) -> Bool) -> Parser<C, C.Element>.Function where C.Element: Equatable {
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
public prefix func %(literal: String) -> Parser<String, String>.Function {
	return { input, index, ifSuccess, ifFailure in
		return input.contains(literal, at: index)
			? ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

public prefix func %<C>(literal: C) -> Parser<C, C>.Function where C: Equatable, C.SubSequence: ToCluster, C.SubSequence.Cluster == C {
	return { input, index, ifSuccess, ifFailure in
		return contains(literal, at: index, from: input)
			? ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

public func parse<C, T>(_ parser: Parser<C, T>.Function, input: C) rethrows -> T where C.Element: Equatable {
	let ifFailure: Parser<C, T>.IfFailure = { e in throw Error(e) }
	let ifSuccess: Parser<C, T>.IfSuccess = { a, _ in a }
	
	return try parser(input, input.startIndex, ifSuccess, ifFailure)
}


