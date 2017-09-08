//
//  GameController.swift
//  2048
//
//  Created by Artem Bobrov on 04.09.17.
//  Copyright © 2017 Artem Bobrov. All rights reserved.
//

import Foundation
import UIKit

class GameController {
	let board: Board
	var score: Int = 0 {
		didSet {
			delegate?.scoreDidChanged(to: score)
		}
	}
	var delegate: GameControllerDelegate?

	var isGameEnded: Bool {
		didSet {
			if !oldValue && isGameEnded {
				delegate?.userDidLost()
			}
		}
	}

	init(board: Board) {
		self.board = board
		isGameEnded = false
	}


	func reset() {
		score = 0
		board.tiles.forEach({ $0?.removeFromSuperview() })
		board.tiles = board.tiles.map({ _ in nil })
	}

	func restart() {
		reset()
		for _ in 0...1 {
			let newValue = getNewValue()
			// TODO: somehow board.emptyTiles as argument
			set(newValue: newValue)
			score += newValue
		}
	}

	func set(newValue value: Int) {
		guard  board.emptyTiles.count > 0 else {
			isGameEnded = true
			return
		}

		var idx = Int(arc4random()) % board.tiles.count
		while board.tiles[idx] != nil {
			idx = Int(arc4random()) % board.tiles.count
		}

		let rect = board.tilesRects[idx]
		setup(newTile: &board.tiles[idx], frame: rect, value: value)
	}

	func setup(newTile tile: inout Tile?, frame: CGRect, value: Int) {
		tile = Tile(radius: Board.radius, size: frame.size, origin: frame.origin)
		tile?.value = value
		board.addSubview(tile!)
		board.bringSubview(toFront: tile!)

		if let tile = tile { // appearance animation
			let scale: CGFloat = 0.25
			tile.transform = CGAffineTransform(scaleX: scale, y: scale)
			tile.alpha = 0
			UIView.animate(withDuration: 0.2, animations: {
				tile.transform = CGAffineTransform(scaleX: 1, y: 1)
				tile.alpha = 1.0
			})
		}
	}

	func check(_ objects: [Any?]) {
		for (idx, object) in objects.enumerated() {
			if let _ = object {
				print("[\(idx % board.dimention), \(idx / board.dimention)]", "not nil")
			} else {
				print("-[\(idx % board.dimention), \(idx / board.dimention)]", "nil")
			}
		}
		print("---------------------------")
	}


	func getNewValue() -> Int {
		let rnd = arc4random() % 10
		return rnd < 2 ? 4 : 2
	}

	func performMove() {

	}
}

extension GameController {
	func move(to direction: MoveDirection) {
		switch direction {
		case .left:
			left()
		case .right:
			right()
		case .up:
			up()
		case .down:
			down()
		}
	}

	private func left() {
	}

	private func right() {
		for _ in 0..<4 {
			for x in 0..<board.dimention {
				let rowIndexes = x * board.dimention..<(x + 1) * board.dimention
				var row = board.tiles[rowIndexes]
				print("row #", x, rowIndexes)

				for y in rowIndexes.dropLast().reversed() {
					print("index: ", y)
					guard let tile =  row[y] else {
						continue
					}
					print("tile: ", tile)
					let location = (x, y % board.dimention)
					if let value = tile.value {
						if canOneTileMoveRight(location: location){
							print("can move to right \(location)")
							delegate?.moveOneTile(from: location, to: (location.0, location.1 + 1), value: value)
							board.tiles[rowIndexes].swapAt(y, y + 1)
						}
					}
				}
			}
		}
	}

	private func up() {

	}

	private func down() {

	}
}

extension GameController {
	func canOneTileMoveRight(location: (Int, Int)) -> Bool {
		return 0..<board.dimention - 1 ~= location.1 && board[location.0, location.1 + 1] == nil
	}

	func tileToLeftHasSameValue(location: (Int, Int), value: Int) -> Bool {
		let (x, y) = location
		guard x != 0 else {
			return false
		}
		if let firstTile = board[x, y],
			let secondTile = board[x - 1, y],
			let first = firstTile.value,
			let second = secondTile.value {
			return first == second
		}
		return false
	}

	func tileToRightHasSameValue(location: (Int, Int), value: Int) -> Bool {
		let (x, y) = location
		guard x != board.dimention - 1 else {
			return false
		}
		if let firstTile = board[x, y],
			let secondTile = board[x + 1, y],
			let first = firstTile.value,
			let second = secondTile.value {
			return first == second
		}
		return false
	}

	func tileAboveHasSameValue(location: (Int, Int), value: Int) -> Bool {
		let (x, y) = location
		guard y != 0 else {
			return false
		}
		if let firstTile = board[x, y],
			let secondTile = board[x, y - 1],
			let first = firstTile.value,
			let second = secondTile.value {
			return first == second
		}
		return false
	}

	func tileBelowHasSameValue(location: (Int, Int), value: Int) -> Bool {
		let (x, y) = location
		guard y != board.dimention - 1 else {
			return false
		}
		if let firstTile = board[x, y],
			let secondTile = board[x, y + 1],
			let first = firstTile.value,
			let second = secondTile.value {
			return first == second
		}
		return false
	}
}
