struct Node {
	var children: [Node]
	var metadata: [Int]
	func sumMetadata() -> Int {
		return metadata.reduce(0, +) + children.lazy.map({ $0.sumMetadata() }).reduce(0, +)
	}
	func value() -> Int {
		if children.isEmpty {
			return sumMetadata()
		}
		return metadata.map({ $0 > children.count ? 0 : children[$0 - 1].value() }).reduce(0, +)
	}
}

func aocD8(_ input: [Int]) {
	var iter = input.makeIterator()
	func readNode() -> Node {
		let numChildren = iter.next()!
		let numMetadata = iter.next()!
		let children = (0..<numChildren).map { _ in readNode() }
		let metadata = (0..<numMetadata).map { _ in iter.next()! }
		return Node(children: children, metadata: metadata)
	}
	let tree = readNode()
	// Part A
	print(tree.sumMetadata())
	// Part B
	print(tree.value())
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let numbers = str.split(separator: " ").map { Int($0)! }

aocD8(numbers)
