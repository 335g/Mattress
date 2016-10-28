//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


public enum ParsingError<Index: Comparable>: Error {
	case notEnd(Index)
	case noReason(Index)
	case rangeOver(Index)
	case notEqual(Index)
	case notAllowNoMatch(Index)
	case debug(Index)
}
