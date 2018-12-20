extension Sequence where Element: Strideable {
	func minmax() -> ClosedRange<Element>? {
		var iter = makeIterator()
		guard var min = iter.next() else { return nil }
		var max = min
		while let next = iter.next() {
			min = Swift.min(min, next)
			max = Swift.max(max, next)
		}
		return min...max
	}
}

extension MutableCollection {
	mutating func mutateEach(_ mutator: (inout Element) throws -> Void) rethrows {
		var i = startIndex
		while i < endIndex {
			try mutator(&self[i])
			formIndex(after: &i)
		}
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

	func convertedDescription(_ converter: (Element) throws -> Character) rethrows -> String {
		return try rows.map({ try String($0.lazy.map(converter)) }).joined(separator: "\n")
	}
}

extension Grid: CustomStringConvertible where Element == Character {
	var description: String {
		return convertedDescription { $0 }
	}
}

enum Spot: Character {
	case wall = "#", room = ".", hdoor = "-", vdoor = "|", start = "X"
	var isDoor: Bool { return self == .hdoor || self == .vdoor }
}

enum Direction: Character {
	case north = "N", east = "E", west = "W", south = "S"
}

extension Point {
	func go(to: Direction) -> Point {
		switch to {
		case .north: return above
		case  .east: return right
		case  .west: return left
		case .south: return below
		}
	}
}

func parse(_ string: Substring) -> Grid<Spot> {
	var currentPoints = [Point(x: 0, y: 0)]
	var prevPoints = [[Point]]()
	var nextPoints = [Set<Point>]()
	var places: [Point: Spot] = [currentPoints[0]: .room]
	func goDirection(_ dir: Direction, from pos: Point) -> Point {
		var pos = pos.go(to: dir)
		if (dir == .north || dir == .south) {
			places[pos] = .hdoor
			places[pos.left] = .wall
			places[pos.right] = .wall
		}
		else {
			places[pos] = .vdoor
			places[pos.above] = .wall
			places[pos.below] = .wall
		}
		pos = pos.go(to: dir)
		places[pos] = .room
		return pos
	}
	for char in string {
		if let direction = Direction(rawValue: char) {
			currentPoints.mutateEach { $0 = goDirection(direction, from: $0) }
		}
		else {
			switch char {
			case "(":
				prevPoints.append(currentPoints)
				nextPoints.append([])
			case "|":
				nextPoints[nextPoints.count - 1].formUnion(currentPoints)
				currentPoints = prevPoints.last!
			case ")":
				nextPoints[nextPoints.count - 1].formUnion(currentPoints)
				currentPoints = Array(nextPoints.popLast()!)
				_ = prevPoints.popLast()
			default:
				fatalError()
			}
		}
	}
	let xBounds = places.lazy.map({ $0.key.x }).minmax()!
	let yBounds = places.lazy.map({ $0.key.y }).minmax()!
	var grid = Grid(repeating: Spot.wall, x: xBounds, y: yBounds)
	for (point, type) in places {
		grid[point] = type
	}
	grid[x: 0, y: 0] = .start
	print(grid.convertedDescription({ $0.rawValue }))
	return grid
}

func aocD20(_ grid: Grid<Spot>) {
	let startingPos = Point(x: 0, y: 0)
	var distance = 0
	var distances = [startingPos: 0]
	var last = [startingPos]
	while !last.isEmpty {
		distance += 1
		var new = [Point]()
		for point in last {
			for direction: Direction in [.north, .east, .south, .west] {
				if grid[point.go(to: direction)].isDoor {
					let newPos = point.go(to: direction).go(to: direction)
					if distances[newPos] == nil {
						new.append(newPos)
						distances[newPos] = distance
					}
				}
			}
		}
		last = new
	}
	print(distance - 1)
	print(distances.filter({ $0.value >= 1000 }).count)
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

var substr = str.dropFirst().dropLast()
let grid = parse(substr)
print(grid.convertedDescription({ $0.rawValue }))
aocD20(grid)
