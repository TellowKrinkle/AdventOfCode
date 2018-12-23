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

struct Instruction {
	var opcode: Opcode
	var a: Int
	var b: Int
	var c: Int
	init?<S: Sequence>(_ seq: S) where S.Element == Substring {
		guard let (opcodestr, astr, bstr, cstr) = seq.tuple4 else { return nil }
		guard let opcode = Opcode(rawValue: String(opcodestr)), let a = Int(astr), let b = Int(bstr), let c = Int(cstr) else { return nil }
		(self.opcode, self.a, self.b, self.c) = (opcode, a, b, c)
	}
}
enum Opcode: String {
	case addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr
	static let allCases: [Opcode] = [.addr, .addi, .mulr, .muli, .banr, .bani, .borr, .bori, .setr, .seti, .gtir, .gtri, .gtrr, .eqir, .eqri, .eqrr]
	func exec(instr: Instruction, reg: inout [Int]) {
		switch self {
		case .addr: reg[instr.c] = reg[instr.a] + reg[instr.b]
		case .addi: reg[instr.c] = reg[instr.a] + instr.b
		case .mulr: reg[instr.c] = reg[instr.a] * reg[instr.b]
		case .muli: reg[instr.c] = reg[instr.a] * instr.b
		case .banr: reg[instr.c] = reg[instr.a] & reg[instr.b]
		case .bani: reg[instr.c] = reg[instr.a] & instr.b
		case .borr: reg[instr.c] = reg[instr.a] | reg[instr.b]
		case .bori: reg[instr.c] = reg[instr.a] | instr.b
		case .setr: reg[instr.c] = reg[instr.a]
		case .seti: reg[instr.c] = instr.a
		case .gtir: reg[instr.c] = instr.a > reg[instr.b] ? 1 : 0
		case .gtri: reg[instr.c] = reg[instr.a] > instr.b ? 1 : 0
		case .gtrr: reg[instr.c] = reg[instr.a] > reg[instr.b] ? 1 : 0
		case .eqir: reg[instr.c] = instr.a == reg[instr.b] ? 1 : 0
		case .eqri: reg[instr.c] = reg[instr.a] == instr.b ? 1 : 0
		case .eqrr: reg[instr.c] = reg[instr.a] == reg[instr.b] ? 1 : 0
		}
	}
}
class Computer {
	var registers: [Int] = [Int](repeating: 0, count: 6)
	var ipBinding: Int
	init(ipBinding: Int) {
		self.ipBinding = ipBinding
	}
	var instructionRegister: Int {
		get {
			return registers[ipBinding]
		}
		set {
			registers[ipBinding] = newValue
		}
	}
	func exec(_ instr: Instruction) {
		instr.opcode.exec(instr: instr, reg: &registers)
	}
}
extension Instruction: CustomStringConvertible {
	var description: String {
		return "\(opcode.rawValue) \(a) \(b) \(c)"
	}
}
func aocD21(_ input: [Instruction], ip: Int) {
	let computer = Computer(ipBinding: ip)
	var set: Set<Int> = []
	var last: Int? = nil
	while input.indices.contains(computer.instructionRegister) {
		let ip = computer.instructionRegister
		if ip == 29 {
			let new = computer.registers[5]
			if last == nil {
				print("Part 1: \(new)")
			}
			if !set.insert(new).inserted {
				print("Part 2: \(last!)")
				return
			}
			last = new
		}
		let instruction = input[ip]
		computer.exec(instruction)
		computer.instructionRegister += 1
	}
	computer.instructionRegister -= 1
	print(computer.registers)
}
import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let split = str.split(separator: "\n")
let binding = Int(split.first!.split(separator: " ")[1])!
let input = split.compactMap { line in
	return Instruction(line.split(separator: " "))
}
aocD21(input, ip: binding)
