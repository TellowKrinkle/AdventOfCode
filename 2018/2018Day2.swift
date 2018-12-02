func count(_ str: Substring) -> (twos: Bool, threes: Bool) {
	let counts = Dictionary(str.lazy.map({ ($0, 1) }), uniquingKeysWith: +)
	let twos = counts.values.contains(2)
	let threes = counts.values.contains(3)
	return (twos, threes)
}

func aocD2a(_ inputStr: String) {
	let input = inputStr.split(separator: "\n").map(count)
	let numTwos = input.lazy.filter({ $0.twos }).count
	let numThrees = input.lazy.filter({ $0.threes }).count
	print(numTwos * numThrees)
}

func areClose(_ a: Substring, _ b: Substring) -> Bool {
	var differences = zip(a, b).lazy.filter({ $0 != $1 }).makeIterator()
	_ = differences.next()
	return differences.next() == nil
}

func aocD2b(_ inputStr: String) {
	let input = inputStr.split(separator: "\n")
	for (aIndex, a) in input.enumerated() {
		for b in input[..<aIndex] {
			if areClose(a, b) {
				print(String(zip(a, b).lazy.filter({ $0 == $1 }).map({ $1 })))
			}
		}
	}
}

import Foundation
let str = try! String(contentsOfFile: CommandLine.arguments[1])
aocD2a(str)
aocD2b(str)
