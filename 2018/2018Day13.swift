struct Point: Hashable {
	var x: Int
	var y: Int

	static func +(lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
}

enum Direction: Character {
	case up = "^", down = "v", left = "<", right = ">"
	var turningLeft: Direction {
		switch self {
		case .up: return .left
		case .down: return .right
		case .right: return .up
		case .left: return .down
		}
	}

	var turningRight: Direction {
		switch self {
		case .up: return .right
		case .down: return .left
		case .right: return .down
		case .left: return .up
		}
	}

	var coords: Point {
		switch self {
		case .up: return Point(x: 0, y: -1)
		case .down: return Point(x: 0, y: 1)
		case .left: return Point(x: -1, y: 0)
		case .right: return Point(x: 1, y: 0)
		}
	}
}

enum Track: Character {
	case vertical = "|", horizontal = "-", diagonalA = "/", diagonalB = "\\", intersection = "+", none = " "

	func go(from: Direction) -> Direction {
		switch self {
		case .vertical, .horizontal: return from
		case .diagonalA:
			switch from {
			case .up: return .right
			case .down: return .left
			case .right: return .up
			case .left: return .down
			}
		case .diagonalB:
			switch from {
			case .up: return .left
			case .down: return .right
			case .right: return .down
			case .left: return .up
			}
		case .intersection, .none: fatalError("Shouldn't use go on track of type \(self)")
		}
	}
}

enum Turn {
	case left, right, straight
	func apply(to direction: Direction) -> Direction {
		switch self {
		case .left: return direction.turningLeft
		case .right: return direction.turningRight
		case .straight: return direction
		}
	}
}

class Cart: CustomStringConvertible {
	var coord: Point

	var facing: Direction
	var nextTurn: Turn = .left
	var removed: Bool = false

	func go(on track: Track) {
		if case .intersection = track {
			facing = nextTurn.apply(to: facing)
			switch nextTurn {
			case .left: nextTurn = .straight
			case .straight: nextTurn = .right
			case .right: nextTurn = .left
			}
		}
		else {
			facing = track.go(from: facing)
		}
		coord = coord + facing.coords
	}

	init(coord: Point, facing: Direction) {
		(self.coord, self.facing) = (coord, facing)
	}

	var description: String {
		return "Cart(coord: \(coord), facing: \(facing), nextTurn: \(nextTurn), removed: \(removed))"
	}
}

func aocD13(_ track: [[Track]], _ carts: [Cart]) {
	var carts = carts
	var positions = Dictionary(uniqueKeysWithValues: carts.lazy.map({ ($0.coord, $0) }) )
	while carts.count > 1 {
		carts.sort(by: { $0.coord.y != $1.coord.y ? $0.coord.y < $1.coord.y : $0.coord.x < $1.coord.x })
		for cart in carts {
			guard !cart.removed else { continue }
			let trackPiece = track[cart.coord.y][cart.coord.x]
			positions[cart.coord] = nil
			cart.go(on: trackPiece)
			if let other = positions[cart.coord] {
				positions[cart.coord] = nil
				print(cart.coord)
				cart.removed = true
				other.removed = true
			}
			else {
				positions[cart.coord] = cart
			}
		}
		carts.removeAll(where: { $0.removed })
		if carts.count == 1 {
			print(carts[0])
		}
	}
}

import Foundation
let str = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))

var carts: [Cart] = []

let track = str.split(separator: "\n").enumerated().map { y, line in
	return line.enumerated().map { x, char -> Track in
		if let dir = Direction(rawValue: char) {
			carts.append(Cart(coord: Point(x: x, y: y), facing: dir))
			return dir == .left || dir == .right ? .horizontal : .vertical
		}
		return Track(rawValue: char)!
	}
}

aocD13(track, carts)
