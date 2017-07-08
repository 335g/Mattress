

public enum AParser<C, T, A> where C: Collection {
	public typealias IfSuccess = (T, C.Index) throws -> A
	public typealias IfFailure = (ParsingError<C>) throws -> A	// always throwing
	public typealias Function = (C, C.Index, IfSuccess, IfFailure) throws -> A
}

public typealias Parser<C, T> = AParser<C, T, Any> where C: Collection

func token<C>(_ pred: @escaping (C.Element) -> Bool, _ next: @escaping (C, C.Index, C.Element) -> C.Index) -> Parser<C, C.Element>.Function where C.Element: Equatable {
	
	return { input, index, ifSuccess, ifFailure in
		if index == input.endIndex {
			return try ifFailure(.alreadyEnd(index))
		}else {
			let elem = input[index]
			
			return pred(elem)
				? try ifSuccess(elem, next(input, index, elem))
				: try ifFailure(.notSatisfaction(index))
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

prefix operator %
public prefix func %(literal: String) -> Parser<String, String>.Function {
	return { input, index, ifSuccess, ifFailure in
		return input.contains(literal, at: index)
			? try ifSuccess(literal, index)
			: try ifFailure(.notMatch(index))
	}
}

public func none<C, T>() -> Parser<C, T>.Function {
	return { _, index, _, ifFailure in
		return try ifFailure(ParsingError<C>.notMatch(index))
	}
}

public func parse<C, T>(_ parser: @escaping Parser<C, T>.Function, input: C) throws -> T where C.Element: Equatable {
	let ifFailure: AParser<C, T, T>.IfFailure = { e in throw Error(e) }
	let ifSuccess: AParser<C, T, T>.IfSuccess = { a, _ in a }
	let parser = parser as! AParser<C, T, T>.Function
	
	return try parser(input, input.startIndex, ifSuccess, ifFailure)
}


