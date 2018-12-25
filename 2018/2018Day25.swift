struct Point4D: Hashable {
	var w: Int
	var x: Int
	var y: Int
	var z: Int

	func manhattanDistance(to other: Point4D) -> UInt {
		return (x-other.x).magnitude + (y-other.y).magnitude + (z-other.z).magnitude + (w-other.w).magnitude
	}
}

func aocD25(_ input: [Point4D]) {
	var closeMap: [Point4D: [Point4D]] = [:]
	for pointA in input {
		for pointB in input {
			if pointA.manhattanDistance(to: pointB) <= 3 {
				closeMap[pointA, default: []].append(pointB)
			}
		}
	}

	var constellations: [[Point4D]] = []
	var used: Set<Point4D> = []
	for point in input {
		if used.contains(point) { continue }
		var working: Set<Point4D> = [point]
		var new = working
		while !new.isEmpty {
			new = Set(working.lazy.flatMap { closeMap[$0]! })
			new.subtract(working)
			working.formUnion(new)
		}
		used.formUnion(working)
		constellations.append(Array(working))
	}
	print(constellations.count)
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

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let split = str.split(separator: "\n")

let input = split.map { line -> Point4D in
	let (w, x, y, z) = line.split(separator: ",").map({ Int($0)! }).tuple4!
	return Point4D(w: w, x: x, y: y, z: z)
}

aocD25(input)
