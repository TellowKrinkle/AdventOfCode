func aocD4(_ input: [(minute: Int, id: Int?, isSleep: Bool)]) {
	var guards: [Int: Int] = [:]
	var sleeping: [Int: [Int: Int]] = [:]
	var current = 0
	var startedSleeping = 0
	for event in input {
		if let id = event.id {
			current = id
		}
		else if event.isSleep {
			startedSleeping = event.minute
		}
		else {
			for i in startedSleeping..<event.minute {
				sleeping[current, default: [:]][i, default: 0] += 1
			}
			guards[current, default: 0] += (event.minute - startedSleeping)
		}
	}
	/* Part A */
	let sleepiest = guards.max(by: { $0.value < $1.value })!.key
	print(sleeping[sleepiest]!.max(by: { $0.value < $1.value })!.key * sleepiest)

	/* Part B */
	let mostSleepyMinutes = sleeping.mapValues({ $0.max(by: { $0.value < $1.value })! })
	let mostSleep = mostSleepyMinutes.max(by: { $0.value.value < $1.value.value })!
	print(mostSleep.key * mostSleep.value.key)
}

import Foundation
let str = try! String(contentsOfFile: CommandLine.arguments[1])
let input = str.split(separator: "\n").sorted().map({ line -> (minute: Int, id: Int?, isSleep: Bool) in
	let numbers = line.split(whereSeparator: { !"0123456789".contains($0) }).map { Int($0)! }
	return (numbers[4], numbers.count > 5 ? numbers[5] : nil, line.contains("falls"))
})

aocD4(input)
