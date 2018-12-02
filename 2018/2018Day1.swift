func aocD1a(_ inputStr: String) {
	let numbers = inputStr.split(separator: "\n").map({ Int($0)! })
	print(numbers.reduce(0, +))
}

func aocD1b(_ inputStr: String) {
	let numbers = inputStr.split(separator: "\n").map({ Int($0)! })
	var seen: Set<Int> = [0]
	var cur = 0
	outerLoop: while true {
		for number in numbers {
			cur += number
			if !seen.insert(cur).inserted {
				break outerLoop;
			}
		}
	}
	print(cur)
}

import Foundation
let str = try! String(contentsOfFile: CommandLine.arguments[1])
aocD1a(str)
aocD1b(str)
