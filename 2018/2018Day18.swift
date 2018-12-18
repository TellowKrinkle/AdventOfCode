extension Collection {
	func get(_ index: Index) -> Element? {
		guard indices.contains(index) else { return nil }
		return self[index]
	}
}

enum Acre: Character {
	case open = ".", trees = "|", lumber = "#"
}

func aocD18(_ input: [[Acre]], target: Int) {
	var area = input
	var previous: [[[Acre]]: Int] = [area: 0]
	var time = 0

	for _ in 0..<target {
		let next = (0..<area.count).map { y in
			return (0..<area.first!.count).map { x -> Acre in
				var trees = 0
				var lumber = 0
				for y2 in (y-1)...(y+1) {
					for x2 in (x-1)...(x+1) {
						switch area.get(y2)?.get(x2) ?? .open {
						case .trees: trees += 1
						case .lumber: lumber += 1
						case .open: break
						}
					}
				}
				let current = area[y][x]
				switch current {
				case .open:
					if trees >= 3 { return .trees }
					else { return .open }
				case .trees:
					if lumber >= 3 { return .lumber }
					else { return .trees }
				case .lumber:
					if lumber >= 2 && trees >= 1 { return .lumber }
					else { return .open }
				}
			}
		}
		area = next
		time += 1
		if let existing = previous[area] {
			let difference = time - existing
			let timeLeft = target - existing
			let finalCycle = timeLeft % difference
			let newArea = previous.lazy.filter({ $0.value == finalCycle + existing }).first!
			area = newArea.key
			break
		}
		else {
			previous[area] = time
		}
	}
	print(area.lazy.map({ String($0.map { $0.rawValue }) }).joined(separator: "\n"))
	let trees = area.lazy.flatMap({ $0 }).filter({ $0 == .trees }).count
	let lumber = area.lazy.flatMap({ $0 }).filter({ $0 == .lumber }).count
	print("\(trees) trees, \(lumber) lumber, rv \(trees * lumber)")
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let input = str.split(separator: "\n").map { line -> [Acre] in
	return line.map { Acre(rawValue: $0)! }
}

aocD18(input, target: 10)
aocD18(input, target: 1000000000)
