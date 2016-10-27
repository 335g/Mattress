//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.



public func between<P1, P2, P3>(_ open: P1, and close: P2) -> (P3) -> IgnoreParser<ConcatParser<P1, P3>, MapParser<P2, P3.Tree>> where
	P1: ParserProtocol,
	P2: ParserProtocol,
	P3: ParserProtocol,
	P1.Targets == P2.Targets,
	P2.Targets == P3.Targets
{
	return { open *> $0 <* close }
}
