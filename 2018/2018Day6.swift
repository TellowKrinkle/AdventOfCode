func aocD6a(_ input: [(x: Int, y: Int)]) {
	var areas = [(count: Int, infinite: Bool)](repeating: (0, false), count: input.count)
	let minX = input.map({ $0.x }).min()!
	let maxX = input.map({ $0.x }).max()!
	let minY = input.map({ $0.y }).min()!
	let maxY = input.map({ $0.y }).max()!
	for x in minX...maxX {
		for y in minY...maxY {
			let distances = input.lazy.map({ ($0 - x).magnitude + ($1 - y).magnitude }).enumerated()
			let minDistance = distances.min(by: { $0.element < $1.element })!.element
			let distancesAtMin = distances.filter({ $0.element == minDistance })
			if distancesAtMin.count > 1 { continue }
			if x == minX || x == maxX || y == minY || y == maxY {
				areas[distancesAtMin[0].offset].infinite = true
			}
			areas[distancesAtMin[0].offset].count += 1
		}
	}
	print(areas.lazy.filter({ !$0.infinite }).map({ $0.count }).max()!)
}

func aocD6b(_ input: [(x: Int, y: Int)]) {
	var count = 0
	let minX = input.map({ $0.x }).min()!
	let maxX = input.map({ $0.x }).max()!
	let minY = input.map({ $0.y }).min()!
	let maxY = input.map({ $0.y }).max()!
	for x in minX...maxX {
		for y in minY...maxY {
			let distances = input.lazy.map({ ($0 - x).magnitude + ($1 - y).magnitude })
			if distances.reduce(0, +) < 10000 {
				count += 1
			}
		}
	}
	print(count)
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let numbers = str.split(separator: "\n").map { line -> (Int, Int) in
	let nums = line.split { " ,".contains($0) }.map { Int($0)! }
	return (nums[0], nums[1])
}

aocD6a(numbers)
aocD6b(numbers)
