//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

@testable import Mattress
import Prelude
import Either

extension ParserProtocol {
	func check(_ input: Targets) -> Tree? {
		return parse(input).either(
			ifLeft: const(nil),
			ifRight: id
		)
	}
}

extension ParserProtocol where Targets == String.CharacterView {
	func check(_ input: String) -> Tree? {
		return check(input.characters)
	}
}

