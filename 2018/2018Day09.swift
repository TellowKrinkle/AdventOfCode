// Compile in release to get the answer in the next century

class Node {
	let value: Int
	var next: Node!
	weak var prev: Node!
	init(_ value: Int, next: Node?, prev: Node?) {
		self.value = value
		self.next = next
		self.prev = prev
	}
	@discardableResult func insertNext(value: Int) -> Node {
		let new = Node(value, next: next, prev: self)
		next.prev = new
		next = new
		return new
	}
	@discardableResult func removePrev() -> Int {
		let ret = prev.value
		prev = prev.prev
		prev.next = self
		return ret
	}
}

func aocD9(players: Int, last: Int) {
	var scores = Array(repeating: 0, count: players)
	var circle = Node(0, next: nil, prev: nil)
	circle.next = circle
	circle.prev = circle
	var turnNum = 0
	for i in 1..<last {
		defer {
			turnNum += 1
			if turnNum == scores.count { turnNum = 0 }
		}
		if i % 23 == 0 {
			scores[turnNum] += i
			for _ in 0..<6 {
				circle = circle.prev
			}
			scores[turnNum] += circle.removePrev()
		}
		else {
			circle = circle.next
			circle = circle.insertNext(value: i)
		}
	}
	// Apparently release can stack overflow
	while circle.next != nil {
		let prev = circle
		circle = circle.next
		prev.next = nil
	}
	print(scores.max()!)
}

aocD9(players: 493, last: 71863)
aocD9(players: 493, last: 71863 * 100)
