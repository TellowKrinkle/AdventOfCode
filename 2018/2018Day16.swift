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

enum Opcode {
	case addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr

	static var allCases: [Opcode] = [.addr, .addi, .mulr, .muli, .banr, .bani, .borr, .bori, .setr, .seti, .gtir, .gtri, .gtrr, .eqir, .eqri, .eqrr]

	func exec(instr: Instruction, input: [Int]) -> [Int] {
		var output = input
		switch self {
		case .addr: output[instr.c] = output[instr.a] + output[instr.b]
		case .addi: output[instr.c] = output[instr.a] + instr.b
		case .mulr: output[instr.c] = output[instr.a] * output[instr.b]
		case .muli: output[instr.c] = output[instr.a] * instr.b
		case .banr: output[instr.c] = output[instr.a] & output[instr.b]
		case .bani: output[instr.c] = output[instr.a] & instr.b
		case .borr: output[instr.c] = output[instr.a] | output[instr.b]
		case .bori: output[instr.c] = output[instr.a] | instr.b
		case .setr: output[instr.c] = output[instr.a]
		case .seti: output[instr.c] = instr.a
		case .gtir: output[instr.c] = instr.a > output[instr.b] ? 1 : 0
		case .gtri: output[instr.c] = output[instr.a] > instr.b ? 1 : 0
		case .gtrr: output[instr.c] = output[instr.a] > output[instr.b] ? 1 : 0
		case .eqir: output[instr.c] = instr.a == output[instr.b] ? 1 : 0
		case .eqri: output[instr.c] = output[instr.a] == instr.b ? 1 : 0
		case .eqrr: output[instr.c] = output[instr.a] == output[instr.b] ? 1 : 0
		}
		return output
	}
}

struct Instruction {
	var opcode: Int
	var a: Int
	var b: Int
	var c: Int
	init?<S: Sequence>(_ seq: S) where S.Element == Int {
		guard let tuple4 = seq.tuple4 else { return nil }
		(opcode, a, b, c) = tuple4
	}
}

func aocD16(_ input: [(from: [Int], instr: Instruction, to: [Int])]) {
	print(input.lazy.map { (from, instr, to) in
		Opcode.allCases.lazy.filter { $0.exec(instr: instr, input: from) == to }.count
	}.filter({ $0 >= 3 }).count)
}

func aocD16b(_ input: [(from: [Int], instr: Instruction, to: [Int])], program: [Instruction]) {
	var possibleMappings = Array(repeating: Opcode.allCases, count: 16)
	for (from, instr, to) in input {
		possibleMappings[instr.opcode].removeAll(where: { $0.exec(instr: instr, input: from) != to })
	}
	var finalMappings = possibleMappings.map { $0.count == 1 ? $0[0] : nil }
	var new = finalMappings.compactMap { $0 }
	while let next = new.popLast() {
		for index in possibleMappings.indices {
			if let i = possibleMappings[index].firstIndex(of: next) {
				possibleMappings[index].remove(at: i)
				if possibleMappings[index].count == 1 {
					finalMappings[index] = possibleMappings[index][0]
					new.append(possibleMappings[index][0])
				}
			}
		}
	}
	let mappings = finalMappings.map { $0! }
	var arr = [0, 0, 0, 0]
	for instruction in program {
		arr = mappings[instruction.opcode].exec(instr: instruction, input: arr)
	}
	print(arr)
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))


let input = str.components(separatedBy: "\n\n").compactMap { block -> (from: [Int], instr: Instruction, to: [Int])? in
	let numbers = block.split(whereSeparator: { !"0123456789".contains($0) }).lazy.map { Int($0)! }
	guard numbers.count == 12 else { return nil }
	let from = Array(numbers[0..<4])
	let instr = Instruction(numbers[4..<8])!
	let to = Array(numbers[8..<12])
	return (from, instr, to)
}

let testProgram = str.components(separatedBy: "\n\n\n\n")[1].split(separator: "\n").map { line in
	return Instruction(line.split(separator: " ").lazy.map { Int($0)! })!
}

aocD16(input)
aocD16b(input, program: testProgram)
