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

	func convertedDescription(_ converter: (Element) throws -> Character) rethrows -> String {
		return try rows.map({ try String($0.lazy.map(converter)) }).joined(separator: "\n")
	}
}

extension Grid: CustomStringConvertible where Element == Character {
	var description: String {
		return convertedDescription { $0 }
	}
}

enum RegionType: Int {
	case rocky = 0, wet = 1, narrow = 2
	init(_ int: Int) {
		self.init(rawValue: int % 3)!
	}
	var char: Character {
		switch self {
		case .rocky: return "."
		case .wet: return "="
		case .narrow: return "|"
		}
	}
}

enum Tool: Int {
	case neither = 0, torch, climbing
	var banned: RegionType {
		switch self {
		case .climbing: return .narrow
		case .torch: return .wet
		case .neither: return .rocky
		}
	}
}

extension Grid: Equatable where Element: Equatable {}

func aocD22(depth: Int, target: Point) {
	var cave = Grid(repeating: RegionType.narrow, x: 0...(target.x * 2), y: 0...(target.y * 2))
	var erosionLevel = Grid(repeating: 0, x: cave.xRange, y: cave.yRange)
	for y in erosionLevel.yRange {
		for x in erosionLevel.xRange {
			let point = Point(x: x, y: y)
			let index: Int
			if point == target {
				index = 0
			}
			else if y == 0 {
				index = x * 16807
			}
			else if x == 0 {
				index = y * 48271
			}
			else {
				index = erosionLevel[x: x-1, y: y] * erosionLevel[x: x, y: y-1]
			}
			erosionLevel[point] = (index + depth) % 20183
			cave[x: x, y: y] = RegionType(erosionLevel[point])
		}
	}

	//	print(cave.convertedDescription({ $0.char }))
	print(cave.storage.lazy.map({ $0.rawValue }).reduce(0, +))
	let bigNumber = Int.max - Int(Int16.max)
	let grid = Grid(repeating: bigNumber, x: cave.xRange, y: cave.yRange)
	var fastest = [grid, grid, grid]
	fastest[Tool.torch.rawValue][x: 0, y: 0] = 0
	var lastFastest = fastest
	repeat {
		lastFastest = fastest
		for distance in 0...(cave.xRange.upperBound + cave.yRange.upperBound) {
			for x in cave.xRange {
				let y = distance - x
				guard cave.yRange.contains(y) else { continue }
				let point = Point(x: x, y: y)
				for ind in (0...2) {
					let tool = Tool(rawValue: ind)!
					guard cave[point] != tool.banned else { continue }
					var best = fastest[ind][point]
					if y > 0 {
						best = min(best, fastest[ind][point.above] + 1)
					}
					if x > 0 {
						best = min(best, fastest[ind][point.left] + 1)
					}
					if y < cave.yRange.upperBound {
						best = min(best, fastest[ind][point.below] + 1)
					}
					if x < cave.xRange.upperBound {
						best = min(best, fastest[ind][point.right] + 1)
					}
					fastest[ind][point] = best
				}
				for ind in (0...2) {
					let tool = Tool(rawValue: ind)!
					guard cave[point] != tool.banned else { continue }
					var best = fastest[ind][point]
					for ind2 in 0...2 {
						best = min(best, fastest[ind2][point] + 7)
					}
					fastest[ind][point] = best
				}
			}
		}
	} while lastFastest != fastest
	print(fastest[Tool.torch.rawValue][target])
}

aocD22(depth: 510, target: Point(x: 10, y: 10))
aocD22(depth: 5355, target: Point(x: 14, y: 796))
