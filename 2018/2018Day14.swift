func aocD13a(_ input: Int) {
	var recipes = [3, 7]
	var elves = [0, 1]
	while recipes.count < (input + 10) {
		let score = elves.lazy.map({ recipes[$0] }).reduce(0, +)
		if score >= 10 {
			recipes.append(score / 10 % 10)
		}
		recipes.append(score % 10)
		elves = elves.map { ($0 + recipes[$0] + 1) % recipes.count }
	}
	print(recipes[input...].prefix(10).map(String.init).joined())
}

func aocD13b(_ input: Int) {
	var target = [Int]()
	var tmp = input
	while tmp > 0 {
		target.insert(tmp % 10, at: 0)
		tmp /= 10
	}
	var recipes = [3, 7]
	var elves = [0, 1]
	while recipes.suffix(target.count) != target[...] && recipes.dropLast().suffix(target.count) != target[...] {
		let score = elves.lazy.map({ recipes[$0] }).reduce(0, +)
		if score >= 10 {
			recipes.append(score / 10 % 10)
		}
		recipes.append(score % 10)
		elves = elves.map { ($0 + recipes[$0] + 1) % recipes.count }
	}
	if recipes.suffix(target.count) == target[...] {
		print(recipes.count - target.count)
	}
	else {
		print(recipes.count - target.count - 1)
	}
}

aocD13a(9)
aocD13a(5)
aocD13a(18)
aocD13a(2018)
aocD13a(540561)
aocD13b(51589)
aocD13b(01245)
aocD13b(92510)
aocD13b(540561)
