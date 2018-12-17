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

struct Point: Hashable, Comparable {
	var x: Int
	var y: Int

	static func +(lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func +=(lhs: inout Point, rhs: Point) {
		lhs = lhs + rhs
	}

	static func <(lhs: Point, rhs: Point) -> Bool {
		return lhs.y != rhs.y ? lhs.y < rhs.y : lhs.x < rhs.x
	}

	/// Point to the left of this one
	var  left: Point { return Point(x: x - 1, y: y) }
	/// Point to the right of this one
	var right: Point { return Point(x: x + 1, y: y) }
	/// Point above this one **on a grid with the origin in the top left**
	var above: Point { return Point(x: x, y: y - 1) }
	/// Point below this one **on a grid with the origin in the top left**
	var below: Point { return Point(x: x, y: y + 1) }

	var adjacent: [Point] {
		return [above, left, right, below]
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

	subscript(point: Point) -> Element {
		get {
			return self[x: point.x, y: point.y]
		}
		set {
			self[x: point.x, y: point.y] = newValue
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
	func pourDown(at point: Point) -> Bool {
		var pt = point
		while map[pt] != .clay {
			map[pt] = .flowingWater
			pt = pt.below
			if !ybounds.contains(pt.y) {
				return true
			}
		}
		repeat {
			// print(map.rows.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
			pt = pt.above
		} while !pourSideways(at: pt) && pt.y > point.y
		return pt != point
	}
	func pourSideways(at point: Point) -> Bool {
		var l = point // Will be moved left until spillage or wall
		var r = point // Will be moved right until spillage or wall
		var spilled = false
		while map[l] != .clay {
			if map[l.below] == .sand {
				// print(map.rows.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(at: l) || spilled
				break
			}
			else if map[l.below] == .flowingWater {
				spilled = true
				break
			}
			map[l] = .water
			l = l.left
		}
		while map[r] != .clay {
			if map[r.below] == .sand {
				// print(map.rows.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(at: r) || spilled
				break
			}
			else if map[r.below] == .flowingWater {
				spilled = true
				break
			}
			map[r] = .water
			r = r.right
		}
		if spilled {
			for x in l.x...r.x {
				if map[x: x, y: l.y] == .water {
					map[x: x, y: l.y] = .flowingWater
				}
			}
		}
		return spilled
	}
	let start = DispatchTime.now()
	_ = pourDown(at: Point(x: 500, y: minY))
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
