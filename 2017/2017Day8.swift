let comparors: [Substring: (Int, Int) -> Bool] = [
	">": { $0 > $1 },
	"<": { $0 < $1 },
	">=": { $0 >= $1 },
	"<=": { $0 <= $1 },
	"==": { $0 == $1 },
	"!=": { $0 != $1 }
]
enum Operation: Substring {
	case inc, dec
	func apply(to variable: inout Int, with number: Int) {
		switch self {
		case .inc: variable += number
		case .dec: variable -= number
		}
	}
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
var variables: [Substring: Int] = [:]
var max = 0
for line in str.split(separator: "\n") {
	let parts = line.split(separator: " ")
	let operation = Operation(rawValue: parts[1])!
	let comparor = comparors[parts[5]]!
	let lhs = Int(parts[4]) ?? variables[parts[4]] ?? 0
	let rhs = Int(parts[6]) ?? variables[parts[6]] ?? 0
	if comparor(lhs, rhs) {
		operation.apply(to: &variables[parts[0], default: 0], with: Int(parts[2])!)
	}
	max = Swift.max(max, variables[parts[0]] ?? 0)
}
print(variables.values.max()!)
print(max)
