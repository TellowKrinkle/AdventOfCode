func aocD4a(_ input: [(String, String)]) {
	var prereqs = [String: Set<String>]()
	var all: Set<String> = []
	for (from, to) in input {
		prereqs[to, default: []].insert(from)
		all.insert(from)
		all.insert(to)
	}
	var available: [String] = all.filter({ !prereqs.keys.contains($0) })
	available.sort(by: { $0 > $1 })
	var order: [String] = []
	while let node = available.popLast() {
		order.append(node)
		for thing in prereqs.keys {
			prereqs[thing]!.remove(node)
			if prereqs[thing]!.isEmpty {
				prereqs[thing] = nil
				available.append(thing)
			}
		}
		available.sort(by: { $0 > $1 })
	}
	print(order.joined().uppercased())
}

func aocD4b(_ input: [(String, String)]) {
	var prereqs = [String: Set<String>]()
	var all: Set<String> = []
	for (from, to) in input {
		prereqs[to, default: []].insert(from)
		all.insert(from)
		all.insert(to)
	}
	var available: [String] = all.filter({ !prereqs.keys.contains($0) })
	available.sort(by: { $0 > $1 })
	func finish(_ node: String) {
		for thing in prereqs.keys {
			prereqs[thing]!.remove(node)
			if prereqs[thing]!.isEmpty {
				prereqs[thing] = nil
				available.append(thing)
			}
		}
		available.sort(by: { $0 > $1 })
	}
	func timeOf(_ str: String) -> Int {
		return 61 + Int(str.utf8.first! - UInt8(ascii: "a"))
	}
	var workers = [(Int, String)](repeating: (0, ""), count: 5)
	var time = 0
	while true {
		for index in workers.indices {
			workers[index].0 -= 1
			if workers[index].0 <= 0 {
				if workers[index].1 != "" {
					finish(workers[index].1)
					workers[index].1 = ""
				}
			}
		}
		for index in workers.indices where workers[index].0 <= 0 {
			if let next = available.popLast() {
				workers[index] = (timeOf(next), next)
			}
		}
		if !workers.contains(where: { $0.0 > 0 }) { break }
		time += 1
	}
	print(time)
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let steps = str.lowercased().split(separator: "\n").map { (line) -> (String, String) in
	let words = line.split(separator: " ")
	let first = words.firstIndex(of: "step")! + 1
	let second = words.lastIndex(of: "step")! + 1
	return (String(words[first]), String(words[second]))
}

aocD4a(steps)
aocD4b(steps)
