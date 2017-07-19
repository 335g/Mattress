
import Runes

/// Parses `open`, followed by `parser` and `close`. Returns the value returned by `parser`.
public func between<C, T, U, V>(_ open: Parser<C, T>, and close: Parser<C, U>) -> (Parser<C, V>) -> Parser<C, V> {
	return { open *> $0 <* close }
}

/// Parses 0 or more `parser` until `end`. Returns the list of values returned by `parser`.
public func many<C, T, U>(_ parser: Parser<C, T>, till end: Parser<C, U>) -> Parser<C, [T]> {
	return many(parser) <* end
}
