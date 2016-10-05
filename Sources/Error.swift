//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


public struct ParsingError<Index: Comparable> {
	let index: Index
	let reason: String
}
