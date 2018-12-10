func aocD5a(_ inputStr: String) {
	var chars = ""
	for char in inputStr {
		guard let prev = chars.last else { chars.append(char); continue }
		if String(prev).lowercased() == String(char).lowercased() && prev != char {
			_ = chars.popLast()
		}
		else {
			chars.append(char)
		}
	}
	print(chars.count)
}

func aocD5b(_ inputStr: String) {
	let lengths = Set(inputStr.lazy.map { String($0).lowercased() }).map { letter -> Int in
		var chars = ""
		for char in inputStr {
			guard String(char).lowercased() != letter else { continue }
			guard let prev = chars.last else { chars.append(char); continue }
			if String(prev).lowercased() == String(char).lowercased() && prev != char {
				_ = chars.popLast()
			}
			else {
				chars.append(char)
			}
		}
		return chars.count
	}
	print(lengths.min()!)
}

import Foundation
let str = try! String(contentsOfFile: CommandLine.arguments[1])

aocD5a(str)
aocD5b(str)
