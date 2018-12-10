struct Point: Hashable {
	var x: Int
	var y: Int
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

func aocD10(_ input: [(position: Point, velocity: Point)]) {
	var points = input
	var output = input
	var count = 0
	while true {
		for index in points.indices {
			points[index].position.x += points[index].velocity.x
			points[index].position.y += points[index].velocity.y
		}
		let range = points.lazy.map({ $0.position.y }).minmax()!
		let prevRange = output.lazy.map({ $0.position.y }).minmax()!
		if range.count > prevRange.count {
			break
		}
		output = points
		count += 1
	}
	let xrange = output.lazy.map({ $0.position.x }).minmax()!
	let yrange = output.lazy.map({ $0.position.y }).minmax()!

	var arr = [[Bool]](repeating: [Bool](repeating: false, count: xrange.count), count: yrange.count)
	for point in output {
		arr[point.position.y - yrange.lowerBound][point.position.x - xrange.lowerBound] = true
	}
	// Part A
	for row in arr {
		print(String(row.lazy.map({ $0 ? "#" : "." })))
	}
	// Part B
	print(count)
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let points = str.split(separator: "\n").map { line -> (Point, Point) in
	let nums = line.split(whereSeparator: { !"-0123456789".contains($0) }).map({ Int($0)! })
	return (Point(x: nums[0], y: nums[1]), Point(x: nums[2], y: nums[3]))
}

aocD10(points)
