func aocD12(_ initial: String, _ rest: [(from: String, to: String)]) {
	var current = Array(initial)
	var updates = [String: Character](uniqueKeysWithValues: rest.lazy.map { ($0, $1.first!) })
	var start = 0
	var time = 0
	var seen: [String: (time: Int, offset: Int)] = [initial: (0, 0)]
	let finalTarget = 50000000000
	var printAt20 = 0
	while true {
		time += 1
		print(String(repeating: " ", count: start+4 > 0 ? start+4 : 0) + String(current))
		var new: [Character] = []
		for index in (-2)..<(current.count+2) {
			let str = String(((index - 2)...(index + 2)).lazy.map { current.get($0) ?? "." })
			let update = updates[str] ?? "."
			new.append(update)
		}
		start -= 2
		let first = new.firstIndex(of: "#")!
		let last = new.lastIndex(of: "#")!
		current = Array(new[first...last])
		start += first
		if let lastSeen = seen[String(current)] {
			let loopTime = time - lastSeen.time
			let finalPos = (finalTarget - lastSeen.time) % loopTime
			let final = seen.filter({ $0.value.time == finalPos + lastSeen.time }).first!

			let posMovement = start - lastSeen.offset
			let totalMovement = posMovement * ((finalTarget - lastSeen.time) / loopTime)
			let finalMovement = final.value.offset + totalMovement
			print(final.key.enumerated().lazy.filter({ $0.element == "#" }).map({ $0.offset + finalMovement }).reduce(0, +))
			break
		}
		else {
			seen[String(current)] = (time, start)
		}
		if (time == 20) {
			printAt20 = current.enumerated().lazy.filter({ $0.element == "#" }).map({ $0.offset + start }).reduce(0, +)
		}
	}
	print("Part A: \(printAt20)")
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let lines = str.split(separator: "\n")
let initial = String(lines[0].split(whereSeparator: { !"#.".contains($0) })[0])
let rest = lines[1...].map { line -> (String, String) in
	let split = line.split(whereSeparator: { !"#.".contains($0) }).lazy.map(String.init)
	return (split[0], split[1])
}

aocD12(initial, rest)
