extension Collection {
	func get(_ index: Index) -> Element? {
		guard indices.contains(index) else { return nil }
		return self[index]
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

	var adjacent: [Point] {
		return [(0, -1), (-1, 0), (1, 0), (0, 1)].map({ Point(x: x + $0.0, y: y + $0.1) })
	}

	func range(in field: [[Space]]) -> [Point] {
		return adjacent.filter { field.get($0.y)?.get($0.x) == .open }
	}

	func distances(in field: [[Space]]) -> [Point: Int] {
		var queue = adjacent.map { ($0, 1) }
		var out: [Point: Int] = [self: 0]
		while let (next, distance) = queue.first {
			queue.remove(at: 0)
			guard field.get(next.y)?.get(next.x) == .open && out[next] == nil else { continue }
			out[next] = distance
			queue.append(contentsOf: next.adjacent.lazy.map({ ($0, distance + 1) }))
		}
		return out
	}
}

enum Space: Character {
	case wall = "#", open = ".", elf = "E", goblin = "G"
}

class Being {
	enum Race: Character {
		case elf = "E", goblin = "G"
	}
	var race: Race
	var coord: Point
	var attackPower = 3
	var hitpoints = 200

	init(race: Race, at: Point, attack: Int) {
		self.race = race
		self.coord = at
		attackPower = attack
	}

	func attackables(in field: [[Space]]) -> [Point] {
		return coord.adjacent.filter {
			let space = field.get($0.y)?.get($0.x)
			return race == .elf && space == .goblin || race == .goblin && space == .elf
		}
	}
}

func fieldString(_ field: [[Space]]) -> String {
	return field.lazy.map({ String($0.lazy.map({ $0.rawValue })) }).joined(separator: "\n")
}

func aocD15(_ input: [[Space]], beings: [Being]) {
	var input = input
	var beings = beings

	print(fieldString(input))
	var rounds = 0
	outerWhile: while true {
		beings.sort(by: { $0.coord < $1.coord })
		var action = false
		defer {
			print(fieldString(input))
			for being in beings where being.hitpoints > 0 {
				print("\(being.race == .elf ? "   Elf" : "Goblin") at \(being.coord): \(being.hitpoints)")
			}
		}
		for being in beings where being.hitpoints > 0 {
			input[being.coord.y][being.coord.x] = .open
			let targets = beings.filter({ being.race != $0.race && $0.hitpoints > 0 })
			if targets.isEmpty {
				break outerWhile
			}
			let inRange = targets.flatMap({ $0.coord.range(in: input) })
			if !inRange.contains(being.coord) {
				let distances = being.coord.distances(in: input)
				let inRangeDistances = inRange.compactMap({ spot in distances[spot].map({ (spot, $0) }) })
				if let nearestDistance = inRangeDistances.min(by: { $0.1 < $1.1 })?.1 {
					let best = inRangeDistances.filter({ $0.1 == nearestDistance }).min(by: { $0.0 < $1.0 })!
					let targetDistances = best.0.distances(in: input)
					let step = being.coord.adjacent
						.compactMap({ point in targetDistances[point].flatMap({ $0 < targetDistances[being.coord]! ? point : nil }) })
						.min()!
					being.coord = step
					action = true
				}
			}
			input[being.coord.y][being.coord.x] = Space(rawValue: being.race.rawValue)!

			let possibleTargets = being.attackables(in: input).lazy.map { point in beings.lazy.filter({ $0.hitpoints > 0 && point == $0.coord }).first! }
			if !possibleTargets.isEmpty {
				action = true
				let target = possibleTargets.min(by: { $0.hitpoints < $1.hitpoints })!
				target.hitpoints -= being.attackPower
				if target.hitpoints <= 0 {
					input[target.coord.y][target.coord.x] = .open
				}
			}
		}
		if !action { break }
		rounds += 1
	}
	let remainingHealth = beings.map({ $0.hitpoints }).filter({ $0 > 0 }).reduce(0, +)
	print("\(rounds) rounds, \(remainingHealth) health, \(rounds * remainingHealth)")
	if beings.lazy.filter({ $0.race == .elf && $0.hitpoints <= 0 }).isEmpty {
		print("No dead elves")
	}
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let baseElfAttack = Int(CommandLine.arguments[2])!

var beings: [Being] = []

let input = str.split(separator: "\n").enumerated().map { y, line in
	line.enumerated().compactMap { x, space -> Space? in
		if let race = Being.Race(rawValue: space) {
			beings.append(Being(race: race, at: Point(x: x, y: y), attack: race == .goblin ? 3 : baseElfAttack))
		}
		return Space(rawValue: space)
	}
}

aocD15(input, beings: beings)
