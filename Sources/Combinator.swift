//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.

extension ParserProtocol {
	public func sandwiched<P1, P2>(between open: P1, and close: P2) -> IgnoreParser<ConcatParser<P1, Self>, MapParser<P2, Self.Tree>>
		where
			P1: ParserProtocol,
			P2: ParserProtocol,
			P1.Targets == Self.Targets,
			P2.Targets == Self.Targets
	{
		return open *> self <* close
	}
}
