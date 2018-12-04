struct Point: Hashable {
	let x: Int
	let y: Int
}

func aocD3a(_ input: [(id: Int, start: Point, size: Point)]) {
	var claimedParts: [Point: Int] = [:]
	for thing in input {
		for x in (thing.start.x..<(thing.start.x + thing.size.x)) {
			for y in (thing.start.y..<(thing.start.y + thing.size.y)) {
				claimedParts[Point(x: x, y: y), default: 0] += 1
			}
		}
	}
	print(claimedParts.values.filter({ $0 >= 2 }).count)
}

func aocD3b(_ input: [(id: Int, start: Point, size: Point)]) {
	var claimedParts: [Point: Int] = [:]
	for thing in input {
		for x in (thing.start.x..<(thing.start.x + thing.size.x)) {
			for y in (thing.start.y..<(thing.start.y + thing.size.y)) {
				claimedParts[Point(x: x, y: y), default: 0] += 1
			}
		}
	}
	outerFor: for thing in input {
		for x in (thing.start.x..<(thing.start.x + thing.size.x)) {
			for y in (thing.start.y..<(thing.start.y + thing.size.y)) {
				if claimedParts[Point(x: x, y: y)] != 1 {
					continue outerFor
				}
			}
		}
		print(thing.id)
	}
}

import Foundation
let str = try! String(contentsOfFile: CommandLine.arguments[1])
let input = str.split(separator: "\n").map { line -> (id: Int, start: Point, size: Point) in
	let parts = line.split(whereSeparator: { " @,:x#".contains($0) }).map { Int($0)! }
	return (parts[0], Point(x: parts[1], y: parts[2]), Point(x: parts[3], y: parts[4]))
}
aocD3a(input)
aocD3b(input)
