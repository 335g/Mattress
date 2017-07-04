
public protocol ToCluster {
	associatedtype Cluster
	
	func toCluster() -> Cluster
}

extension ArraySlice: ToCluster {
	public func toCluster() -> Array<Element> {
		return Array(self)
	}
}

extension MutableSlice: ToCluster {
	public func toCluster() -> Array<Base._Element> {
		return Array(self)
	}
}

