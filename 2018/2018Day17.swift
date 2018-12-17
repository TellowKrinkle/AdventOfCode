enum Area {
	case sand, clay, water, flowingWater
	var char: Character {
		switch self {
		case .sand: return "."
		case .clay: return "#"
		case .water: return "~"
		case .flowingWater: return "|"
		}
	}

	var isWater: Bool {
		return self == .water || self == .flowingWater
	}
}

struct Grid<Element> {
	var xRange: ClosedRange<Int>
	var yRange: ClosedRange<Int>
	var storage: [Element]

	init(repeating element: Element, x: ClosedRange<Int>, y: ClosedRange<Int>) {
		xRange = x
		yRange = y
		storage = [Element](repeating: element, count: xRange.count * yRange.count)
	}

	subscript(x x: Int, y y: Int) -> Element {
		get {
			precondition(xRange.contains(x) && yRange.contains(y))
			let xIndex = x - xRange.lowerBound
			let yIndex = y - yRange.lowerBound
			return storage[xRange.count * yIndex + xIndex]
		}
		set {
			precondition(xRange.contains(x) && yRange.contains(y))
			let xIndex = x - xRange.lowerBound
			let yIndex = y - yRange.lowerBound
			storage[xRange.count * yIndex + xIndex] = newValue
		}
	}

	func row(at y: Int) -> ArraySlice<Element> {
		precondition(yRange.contains(y))
		let yIndex = y - yRange.lowerBound
		return storage[(yIndex * xRange.count)..<((yIndex + 1) * xRange.count)]
	}

	var rows: LazyMapCollection<ClosedRange<Int>, ArraySlice<Element>> {
		return yRange.lazy.map { self.row(at: $0) }
	}
}

import Dispatch

func aocD17(_ input: [(x: ClosedRange<Int>, y: ClosedRange<Int>)]) {
	let minX = input.lazy.map { $0.x.lowerBound }.min()! - 1
	let maxX = input.lazy.map { $0.x.upperBound }.max()! + 1
	let minY = input.lazy.map { $0.y.lowerBound }.min()!
	let maxY = input.lazy.map { $0.y.upperBound }.max()!
	let xbounds = minX...maxX
	let ybounds = minY...maxY
	var map = Grid(repeating: Area.sand, x: xbounds, y: ybounds)
	for (xrange, yrange) in input {
		for x in xrange {
			for y in yrange {
				map[x: x, y: y] = .clay
			}
		}
	}
	func pourDown(x: Int, y: Int) -> Bool {
		var newY = y
		while map[x: x, y: newY] != .clay {
			map[x: x, y: newY] = .flowingWater
			newY += 1
			if !ybounds.contains(newY) {
				return true
			}
		}
		repeat {
			// print(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
			newY -= 1
		} while !pourSideways(x: x, y: newY) && newY > y
		return newY != y
	}
	func pourSideways(x: Int, y: Int) -> Bool {
		var lX = x
		var rX = x
		var spilled = false
		while map[x: lX, y: y] != .clay {
			let below = map[x: lX, y: y + 1]
			if below == .sand {
				// print(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(x: lX, y: y) || spilled
				break
			}
			else if below == .flowingWater {
				spilled = true
				break
			}
			map[x: lX, y: y] = .water
			lX -= 1
		}
		while map[x: rX, y: y] != .clay {
			let below = map[x: rX, y: y + 1]
			if below == .sand {
				// print(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(x: rX, y: y) || spilled
				break
			}
			else if below == .flowingWater {
				spilled = true
				break
			}
			map[x: rX, y: y] = .water
			rX += 1
		}
		if spilled {
			for x in lX...rX {
				if map[x: x, y: y] == .water {
					map[x: x, y: y] = .flowingWater
				}
			}
		}
		return spilled
	}
	let start = DispatchTime.now()
	_ = pourDown(x: 500, y: minY)
	let end = DispatchTime.now()
	let allWater = map.storage.lazy.filter({ $0.isWater }).count
	let containedWater = map.storage.lazy.filter({ $0 == .water }).count
	let endCounting = DispatchTime.now()
	print(map.rows.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
	print("""
		      All water: \(allWater)
		Contained water: \(containedWater)
		      Pour time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000)µs
		  Counting time: \(Double(endCounting.uptimeNanoseconds - end.uptimeNanoseconds) / 1_000)µs
		""")
}

extension Sequence {
	var tuple3: (Element, Element, Element)? {
		var iter = makeIterator()
		guard let first  = iter.next(),
		      let second = iter.next(),
		      let third  = iter.next()
		else { return nil }
		return (first, second, third)
	}
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let input = str.split(separator: "\n").map { line -> (x: ClosedRange<Int>, y: ClosedRange<Int>) in
	let (a, bstart, bend) = line.split(whereSeparator: { !"0123456789-".contains($0) }).map({ Int($0)! }).tuple3!
	if line.first == "x" {
		return (x: a...a, y: bstart...bend)
	}
	else {
		return (x: bstart...bend, y: a...a)
	}
}

aocD17(input)
