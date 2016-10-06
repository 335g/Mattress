//  Copyright (C) 2016 Yoshiki Kudo. All rights reserved.


///
/// higher priority
///
///   ↑
///   ↓
///
/// lower priority
///

// TODO: fix the priorities

// MARK: - Map

precedencegroup Map {
	associativity: left
	higherThan: Concaternation
}

// MARK: - Concaternation

precedencegroup Concaternation {
	associativity: left
	higherThan: WeakConcaternation
}

// MARK: - WeakConcaternation

precedencegroup WeakConcaternation {
	associativity: left
	higherThan: Alternation
}


// MARK: - Alternation

precedencegroup Alternation {
	associativity: left
	lowerThan: ComparisonPrecedence
	higherThan: LogicalConjunctionPrecedence
}

// TODO: add document
///
///
prefix operator %

// TODO: add document
///
///
postfix operator *

// TODO: add document
///
///
postfix operator +

// TODO: add document
///
///
infix operator <*> : Concaternation
infix operator  *> : Concaternation
infix operator <*  : Concaternation

// TODO: add document
///
///
infix operator >>- : WeakConcaternation

// TODO: add document
///
///
infix operator <|> : Alternation

// TODO: add document
///
///
infix operator <^> : Map
infix operator <^  : Map

