enum Opcode: String {
	case addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr
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

struct Instruction {
	var opcode: Opcode
	var a: Int
	var b: Int
	var c: Int
	init?<S: Sequence>(_ seq: S) where S.Element == Substring {
		guard let tuple4 = seq.tuple4 else { return nil }
		let (opcodestr, astr, bstr, cstr) = tuple4
		guard let opcode = Opcode(rawValue: String(opcodestr)), let a = Int(astr), let b = Int(bstr), let c = Int(cstr) else { return nil }
		(self.opcode, self.a, self.b, self.c) = (opcode, a, b, c)
	}
}

extension Instruction: CustomStringConvertible {
	var description: String {
		return "\(opcode.rawValue) \(a) \(b) \(c)"
	}
}

extension Instruction {
	func cOp(ip: Int, index: Int) -> String {
		let ra = a == ip ? "\(index)" : "r[\(a)]"
		let rb = b == ip ? "\(index)" : "r[\(b)]"
		switch opcode {
		case .addr: return "\(ra) + \(rb)"
		case .addi: return "\(ra) + \(b)"
		case .mulr: return "\(ra) * \(rb)"
		case .muli: return "\(ra) * \(b)"
		case .banr: return "\(ra) & \(rb)"
		case .bani: return "\(ra) & \(b)"
		case .borr: return "\(ra) | \(rb)"
		case .bori: return "\(ra) | \(b)"
		case .setr: return "\(ra)"
		case .seti: return "\(a)"
		case .gtir: return "\(a) > \(rb) ? 1 : 0"
		case .gtri: return "\(ra) > \(b) ? 1 : 0"
		case .gtrr: return "\(ra) > \(rb) ? 1 : 0"
		case .eqir: return "\(a) == \(rb) ? 1 : 0"
		case .eqri: return "\(ra) == \(b) ? 1 : 0"
		case .eqrr: return "\(ra) == \(rb) ? 1 : 0"
		}
	}
}

func makeC(_ input: [Instruction], ip: Int, allowAllJumps: Bool = false) -> String {
	func finalizingStatement(str pos: String) -> String {
		return "r[\(ip)] = \(pos); printRegs(r); return 0;"
	}
	func finalizingStatement(at pos: Int) -> String {
		return finalizingStatement(str: String(pos))
	}
	let doJumpMacro = """
		#define doJump(x, line) switch (x) { \(input[1...].indices.lazy.map({ "case \($0-1): goto l\($0);" }).joined(separator: " ")) default: \(finalizingStatement(str: "(line)")) }
		"""
	let badJumpMacro = """
		#define badJump(line, reg) if (1) { fprintf(stderr, "Made a jump at l%d with an unsupported offset of %ld.  Only offsets of 0 and 1 are supported.\\n", (line), (reg)); abort(); }
		"""
	var finalOutput = """
		#import <stdlib.h>
		#import <stdio.h>
		\(allowAllJumps ? doJumpMacro : badJumpMacro)
		void printRegs(long *r) {
			printf("%ld %ld %ld %ld %ld %ld\\n", r[0], r[1], r[2], r[3], r[4], r[5]);
		}
		int main(int argc, char **argv) {
			long r[6] = {0};
			for (int i = 0; i < (argc > 6 ? 6 : argc - 1); i++) {
				r[i] = atoi(argv[i+1]);
			}\n
		"""
	var instrs = [Int]()
	func makeGoto(_ target: Int, index: Int) -> String {
		if input.indices.contains(target) {
			return "goto l\(target);"
		}
		else {
			return finalizingStatement(at: index)
		}
	}

	let lines = input.enumerated().map { (pair) -> String in
		let (index, instr) = pair
		if instr.c == ip {
			let jump = "doJump(\(instr.cOp(ip: ip, index: index)), \(index))"
			switch (instr.opcode, instr.a, instr.b) {
			case (.addr, instr.c, instr.c):
				return makeGoto(index * 2 + 1, index: index)
			case (.addr, instr.c, _):
				return allowAllJumps ? jump : "if (r[\(instr.b)] == 0) { goto l\(index+1); } else if (r[\(instr.b)] == 1) { goto l\(index+2); } else { badJump(\(index), r[\(instr.b)]); }"
			case (.addr, _, instr.c):
				return allowAllJumps ? jump : "if (r[\(instr.a)] == 0) { goto l\(index+1); } else if (r[\(instr.a)] == 1) { goto l\(index+2); } else { badJump(\(index), r[\(instr.a)]); }"
			case (.addi, instr.c, _):
				return makeGoto(index + instr.b + 1, index: index)
			case (.muli, instr.c, _):
				return makeGoto(index * instr.b + 1, index: index)
			case (.mulr, instr.c, instr.c):
				return makeGoto(index * index + 1, index: index)
			case (.seti, _, _):
				return makeGoto(instr.a + 1, index: index)
			default:
				if !allowAllJumps { fatalError("Unsupported jump operation: \(instr), maybe add -allJumps to switch to all jumps mode?") }
				return jump
			}
		}
		else {
			return "r[\(instr.c)] = \(instr.cOp(ip: ip, index: index));"
		}
	}

	for (index, line) in lines.enumerated() {
		finalOutput += "\tl\(index): "
		finalOutput += line
		finalOutput += "\n"
	}
	finalOutput += "\t"
	finalOutput += finalizingStatement(at: input.count - 1)
	finalOutput += "\n}"
	return finalOutput
}

import Foundation

guard CommandLine.arguments.count > 1 else {
	print("""
		Usage: \(CommandLine.arguments[0]) aocProgram.txt [-allJumps] > aocProgram.c

		If run without `-allJumps`, only some jump operations will be allowed,
		and offset-based jumps will be limited to 0 or 1 (the output of gt and eq checks)
		Otherwise, all jumps will be allowed, which may reduce the quality of
		the C compiler's output

		The outputted C program can be run with anywhere from 0 to 6 arguments,
		representing the starting registers.  Registers not passed will start a 0
		""")
	exit(EXIT_FAILURE)
}

let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

let split = str.split(separator: "\n")
let binding = Int(split.first!.split(separator: " ")[1])!

let input = split.compactMap { line in
	return Instruction(line.split(separator: " "))
}

let allJumps = CommandLine.arguments[1...].lazy.map({ $0.lowercased() }).contains("-alljumps")

print(makeC(input, ip: binding, allowAllJumps: allJumps))
