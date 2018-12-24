class Unit: CustomStringConvertible {
	let id: (String, Int)
	var num: Int
	struct Info {
		var hp: Int
		var weak: [String]
		var immune: [String]
		var attackType: String
		var damage: Int
		var initiative: Int

		init(_ parts: [Substring]) {
			hp = Int(parts[4])!
			let attackInfo: [Substring]
			if parts[7].first == "(" {
				let end = parts.firstIndex(where: { $0.contains(")") })!
				attackInfo = Array(parts[(end + 1)...])
				let resistances = parts[7...end].joined(separator: " ")
				let resParts = resistances.dropFirst().dropLast().split(separator: ";")
				var immune = [String]()
				var weak = [String]()
				for part in resParts {
					let partPieces = part.split { ", ".contains($0) }
					if partPieces[0] == "immune" {
						immune = partPieces[2...].map(String.init)
					}
					else if partPieces[0] == "weak" {
						weak = partPieces[2...].map(String.init)
					}
					else {
						fatalError()
					}
				}
				(self.immune, self.weak) = (immune, weak)
			}
			else {
				weak = []
				immune = []
				attackInfo = Array(parts[7...])
			}
			damage = Int(attackInfo[5])!
			attackType = String(attackInfo[6])
			initiative = Int(attackInfo[10])!
		}
	}
	var info: Info
	var effectivePower: Int {
		return num * info.damage
	}
	init(_ str: Substring, id: (String, Int)) {
		let parts = str.split(separator: " ")
		num = Int(parts[0])!
		info = Info(parts)
		self.id = id
	}
	init(num: Int, info: Info, id: (String, Int)) {
		(self.num, self.info, self.id) = (num, info, id)
	}

	func copy() -> Unit {
		return Unit(num: num, info: info, id: id)
	}

	func calculateDamage(against other: Unit) -> Int {
		let multiplier: Int
		if other.info.weak.contains(info.attackType) {
			multiplier = 2
		}
		else if other.info.immune.contains(info.attackType) {
			multiplier = 0
		}
		else {
			multiplier = 1
		}
		return effectivePower * multiplier
	}

	func chooseTarget(in army: [Unit]) -> Unit? {
		let out = army.max { a, b in
			let aDmg = calculateDamage(against: a)
			let bDmg = calculateDamage(against: b)
			if aDmg == bDmg {
				return a.effectivePower == b.effectivePower ? a.info.initiative < b.info.initiative : a.effectivePower < b.effectivePower
			}
			return aDmg < bDmg
		}
		if out.map({ calculateDamage(against: $0) }) == 0 { return nil }
		return out
	}

	func applyDamage(_ damage: Int) {
		let unitsDown = min(damage / info.hp, num)
		num -= unitsDown
		// print("\(unitsDown) units defeated")
	}

	var description: String {
		return "\(id.0) \(id.1) (\(num) units)"
	}
}

func aocD23(immune: [Unit], infection: [Unit]) -> (immune: [Unit], infection: [Unit]) {
	var immune = immune
	var infection = infection
	while !immune.isEmpty && !infection.isEmpty {
		var targets = [(Unit, Unit)]()
		var untargetedImmune = immune
		for unit in infection.sorted(by: { $0.effectivePower == $1.effectivePower ? $0.info.initiative > $1.info.initiative : $0.effectivePower > $1.effectivePower }) {
			if let target = unit.chooseTarget(in: untargetedImmune) {
				// print("\(unit) chose \(target) and expects to do \(unit.calculateDamage(against: target)) damage")
				targets.append((unit, target))
				untargetedImmune.removeAll(where: { $0 === target })
			}
			else {
				// print("\(unit) found no targets")
			}
		}
		var untargetedInfection = infection
		for unit in immune.sorted(by: { $0.effectivePower == $1.effectivePower ? $0.info.initiative > $1.info.initiative : $0.effectivePower > $1.effectivePower }) {
			if let target = unit.chooseTarget(in: untargetedInfection) {
				// print("\(unit) chose \(target) and expects to do \(unit.calculateDamage(against: target)) damage")
				targets.append((unit, target))
				untargetedInfection.removeAll(where: { $0 === target })
			}
			else {
				// print("\(unit) found no targets")
			}
		}
		targets.sort(by: { $0.0.info.initiative > $1.0.info.initiative })
		var isDone = true
		for (a, b) in targets {
			let damage = a.calculateDamage(against: b)
			if damage >= b.info.hp {
				isDone = false
			}
			// print("\(a) attacks \(b) doing \(damage) damage.  ", terminator: "")
			b.applyDamage(damage)
		}
		immune.removeAll(where: { $0.num <= 0 })
		infection.removeAll(where: { $0.num <= 0 })
		if isDone { break }
	}
	return (immune, infection)
}


import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let split = str.split(separator: "\n")

var immune = [Unit]()
var infection = [Unit]()

var isInfection = false

for line in split {
	if Int(String(line.first ?? "!")) != nil {
		let unit = Unit(line, id: (isInfection ? "Infection" : "Immune", (isInfection ? infection.count : immune.count) + 1))
		if isInfection {
			infection.append(unit)
		}
		else {
			immune.append(unit)
		}
	}
	if line.contains("Infection:") {
		isInfection = true
	}
}

do {
	let (imm, inf) = aocD23(immune: immune.map { $0.copy() }, infection: infection.map { $0.copy() })
	print("""
		Part 1:
			   Immune: \(imm) total: \(imm.lazy.map({ $0.num }).reduce(0, +))
			Infection: \(inf) total: \(inf.lazy.map({ $0.num }).reduce(0, +))
		""")
}

for boost in 1... {
	let newImmune = immune.map { $0.copy() }
	newImmune.forEach { $0.info.damage += boost }
	let (imm, inf) = aocD23(immune: newImmune, infection: infection.map { $0.copy() })
	if !imm.isEmpty && inf.isEmpty {
		print("Part 2: Immune: \(imm) total: \(imm.lazy.map({ $0.num }).reduce(0, +))")
		break
	}
}
