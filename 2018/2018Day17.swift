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

func aocD17(_ input: [(x: ClosedRange<Int>, y: ClosedRange<Int>)]) {
	let minX = input.lazy.map { $0.x.lowerBound }.min()! - 1
	let maxX = input.lazy.map { $0.x.upperBound }.max()! + 1
	let minY = input.lazy.map { $0.y.lowerBound }.min()!
	let maxY = input.lazy.map { $0.y.upperBound }.max()!
	let xbounds = minX...maxX
	let ybounds = minY...maxY
	var map = [[Area]](repeating: [Area](repeating: .sand, count: xbounds.count), count: ybounds.count)
	for (xrange, yrange) in input {
		for x in xrange {
			for y in yrange {
				map[y - minY][x - minX] = .clay
			}
		}
	}
	func pourDown(x: Int, y: Int) -> Bool {
		var newY = y
		while map[newY-minY][x-minX] != .clay {
			map[newY-minY][x-minX] = .flowingWater
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
		while map[y-minY][lX-minX] != .clay {
			let below = map[y-minY + 1][lX-minX]
			if below == .sand {
				// print(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(x: lX, y: y) || spilled
				break
			}
			else if below == .flowingWater {
				spilled = true
				break
			}
			map[y-minY][lX-minX] = .water
			lX -= 1
		}
		while map[y-minY][rX-minX] != .clay {
			let below = map[y-minY + 1][rX-minX]
			if below == .sand {
				// rint(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
				spilled = pourDown(x: rX, y: y) || spilled
				break
			}
			else if below == .flowingWater {
				spilled = true
				break
			}
			map[y-minY][rX-minX] = .water
			rX += 1
		}
		if spilled {
			for x in lX...rX {
				if map[y-minY][x-minX] == .water {
					map[y-minY][x-minX] = .flowingWater
				}
			}
		}
		return spilled
	}
	_ = pourDown(x: 500, y: minY)
	print(map.lazy.map({ String($0.lazy.map { $0.char }) }).joined(separator: "\n"))
	print("""
		      All water: \(map.lazy.flatMap({ $0 }).filter({ $0.isWater }).count)
		Contained water: \(map.lazy.flatMap({ $0 }).filter({ $0 == .water }).count)
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
