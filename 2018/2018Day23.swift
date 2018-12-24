struct Point3D: Equatable {
	var x: Int
	var y: Int
	var z: Int

	func manhattanDistance(to other: Point3D) -> UInt {
		return (x-other.x).magnitude + (y-other.y).magnitude + (z-other.z).magnitude
	}
}

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

func aocD23a(_ input: [(pt: Point3D, radius: Int)]) {
	let largest = input.max(by: { $0.radius < $1.radius })!
	let inRange = input.filter { $0.pt.manhattanDistance(to: largest.pt) <= largest.radius }

	print(inRange.count)
}

func aocD23b(_ input: [(pt: Point3D, radius: Int)], searchSize: Int) {
	// Will search searchSize^3 points each round
	// Bigger numbers are more likely to find the solution but are slower
	let xRange = input.lazy.map({ $0.pt.x }).minmax()!
	let yRange = input.lazy.map({ $0.pt.y }).minmax()!
	let zRange = input.lazy.map({ $0.pt.z }).minmax()!

	let largestRange = max(xRange.count, max(yRange.count, zRange.count))
	let center = Point3D(x: 0, y: 0, z: 0)
	var best = center
	var bestScore = 0

	for stepPower in (0...32).reversed() {
		let step = 1 << stepPower
		let offset = (step * searchSize) / 2
		guard offset < largestRange else { continue }
		// Shift points around slightly to raise chances of finding new minimums
		let negOffset = step / 2 - offset
		let posOffset = step / 2 + offset
		let xSearch = stride(from: best.x + negOffset, to: best.x + posOffset, by: step)
		let ySearch = stride(from: best.y + negOffset, to: best.y + posOffset, by: step)
		let zSearch = stride(from: best.z + negOffset, to: best.z + posOffset, by: step)
		for x in xSearch {
			for y in ySearch {
				for z in zSearch {
					let point = Point3D(x: x, y: y, z: z)
					let score = input.lazy.filter({ $0.pt.manhattanDistance(to: point) <= $0.radius }).count
					if score > bestScore {
						best = point
						bestScore = score
					}
					else if score == bestScore && best.manhattanDistance(to: center) > point.manhattanDistance(to: center) {
						best = point
					}
				}
			}
		}
		print("\(bestScore) bots in range of \(best) which is \(best.manhattanDistance(to: center)) from the center")
	}
}

extension Sequence {
	var tuple4: (Element, Element, Element, Element)? {
		var iter = makeIterator()
		guard let first  = iter.next(),
		      let second = iter.next(),
		      let third  = iter.next(),
		      let fourth = iter.next()
		else { return nil }
		return (first, second, third, fourth)
	}
}

extension Collection {
	func get(_ index: Index) -> Element? {
		guard indices.contains(index) else { return nil }
		return self[index]
	}
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let split = str.split(separator: "\n")
let input = split.map { line -> (pt: Point3D, radius: Int) in
	let (x, y, z, r) = line.split(whereSeparator: { !"0123456789-".contains($0) }).map({ Int($0)! }).tuple4!
	return (pt: Point3D(x: x, y: y, z: z), radius: r)
}

let searchSize = CommandLine.arguments.get(2).flatMap(Int.init) ?? 32

aocD23a(input)
aocD23b(input, searchSize: searchSize)
