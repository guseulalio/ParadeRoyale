//
//  PlayingTable.swift
//  ParadeRoyale
//
//  Created by Gustavo E M Cabral on 13/7/20.
//  Copyright © 2020 Gustavo Eulalio. All rights reserved.
//

import SwiftUI

enum CardLocation: Equatable
{
	case acePile
	case dispensePile(stack: Int)
	case board(row: Int, stack: Int)
	case none
	
	static func != (lhs: CardLocation, rhs: CardLocation) -> Bool
	{
		switch lhs
		{
			case .acePile: if rhs == .acePile { return false }
			case .none: if rhs == .none { return false }
			case .dispensePile(let stack): if rhs == .dispensePile(stack: stack) { return false }
			case .board(let row, let stack): if rhs == .board(row: row, stack: stack) { return false }
		}
		return true
	}
}

struct PlayingTable: View {
	// MARK: - PROPERTIES
	@State private var board = [[[String?]]]()
	@State private var stockPile = [[String]]()
	@State private var acePile = [String]()
	@State private var dispensePile = [String]()
	
	@State private var showResetConfirmationAlert = false
	@State private var gameWon = false
	
	@State private var gameEndOpacity = 0.0
	@State private var gameEndScale = 0.3
	
	
	
	// MARK: - BODY
	var body: some View {
		GeometryReader { geo in
			ZStack {
				LinearGradient(gradient: Gradient(colors: [Color.green, Color.black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
				HStack {
					VStack {
						// BOARD
						ForEach(self.board, id:\.self) { line in
							HStack {
								ForEach(line, id:\.self) { cardStack in
									Button(action: {
										guard !cardStack.isEmpty else { return }
										
										if let card = cardStack.last! {
											let destination = self.findDestination(for: card)
											
											switch destination {
											case let .board(row, stack):
												if let rowIndex = self.board.firstIndex(of: line) {
													if let colIndex = self.board[rowIndex].firstIndex(of: cardStack) {
														self.board[row][stack].append(card)
														self.board[rowIndex][colIndex].removeLast()
													} else {
														fatalError("Stack not found")
													}
												} else {
													fatalError("Row not found")
												}
											case .acePile:
												let rowIndex = self.board.firstIndex(of: line) ?? 0
												let colIndex = self.board[rowIndex].firstIndex(of: cardStack) ?? 0
												self.acePile.append(card)
												self.board[rowIndex][colIndex].removeLast()
											default:
												break
											}
										}
									}) {
										Color.clear
									}
									.background(
										self.cardImageFrom(string: cardStack.last)
											.resizable()
											.scaledToFit()
									)
									.frame(width: 40)
								}
							}
						}.padding(5)
						
						// STOCKPILE
						HStack {
							ForEach(self.stockPile, id: \.self) { col in
								ZStack {
									Image(CardBox.emptySpot).resizable().scaledToFit().frame(width: 40)
									
									ForEach(0..<col.count) { cardIndex in
										Button(action: {
											let destination = self.findDestination(for: col[cardIndex])
											
											switch destination {
											case let CardLocation.board(row, stack):
												self.board[row][stack].append(col[cardIndex])
												if let colIndex = self.stockPile.firstIndex(of: col) {
													self.stockPile[colIndex].removeLast()
												} else {
													fatalError("Stack not found")
												}
											case .acePile:
												if let colIndex = self.stockPile.firstIndex(of: col) {
													self.acePile.append(col[cardIndex])
													self.stockPile[colIndex].removeLast()
												} else {
													fatalError("Stack not found")
												}
											default:
												break
											}
											self.checkForGameWin()
										}) {
											Color.clear
										}.background(
											self.cardImageFrom(string: col[cardIndex], emptyCheck: false)
												.resizable()
												.scaledToFit()
										)
										.frame(width: 40)
										.offset(CGSize(width: 0, height: cardIndex * 10))
									}
								}
							}
						}.padding(5)
						Spacer(minLength: 80)
					}
					VStack {
						// ACE PILE
						if self.acePile.isEmpty {
							Image(CardBox.emptySpot).resizable().scaledToFit().frame(width: 40).padding()
						} else {
							self.cardImageFrom(string: self.acePile[self.acePile.count - 1]).resizable().scaledToFit().frame(width: 40).padding()
						}
						
						Spacer()
						
						Button(action: {
							if self.dispensePile.isEmpty {
								self.resetBoard()
							} else {
								self.showResetConfirmationAlert = true
							}
						}) {
							Image(systemName: "arrow.clockwise").frame(width: 40, height: 40)
								.padding(.horizontal, 16)
								.padding(.bottom, 6)
								.background(Color.red).foregroundColor(.white)
								.clipShape(Capsule())
						}
//						Button(action: {
//							self.gameWon = true
//							withAnimation(.spring()) {
//								self.gameEndOpacity = 1.0
//								self.gameEndScale = 1.0
//							}
//						}) {
//							Image(systemName: "flame").frame(width: 40, height: 40)
//								.padding(.horizontal, 16)
//								.padding(.bottom, 6)
//								.background(Color.red).foregroundColor(.white)
//								.clipShape(Capsule())
//						}
						
						Spacer()
						
						// DISPENSE PILE
						ZStack {
							Button(action: {
								if !self.dispensePile.isEmpty {
									let ceiling = min(self.stockPile.count, self.dispensePile.count)
									for i in 0..<ceiling {
										self.stockPile[i].append(self.dispensePile.removeLast())
									}
								}
								self.checkForGameWin()
							}) {
								Color.clear.frame(width: 40)
							}.background(Image(self.dispensePile.isEmpty ? CardBox.emptySpot : CardBox.cardBack).resizable().scaledToFit().frame(width: 40))
						}.padding()
					}.padding()
				}
				if self.gameWon {
					ZStack {
						Image("boom")
							.resizable().scaledToFit()
							.frame(width: CGFloat(self.gameEndScale) * geo.size.height, height: CGFloat(self.gameEndScale) * geo.size.height)
						Button(action: {
							self.resetBoard()
						}) {
							ZStack {
								Text("You\nWon!").font(Font.custom("MarkerFelt-Wide", size: 64))
								.foregroundColor(.black)
								Text("You\nWon!").font(Font.custom("MarkerFelt-Wide", size: 64))
								.offset(CGSize(width: 5, height: -5))
								.foregroundColor(.red)
							}
						}
					}
					.opacity(self.gameEndOpacity)
				}
			}
			.alert(isPresented: self.$showResetConfirmationAlert, content: {
				let confirmButton = Alert.Button.default(Text("Yes"), action: self.resetBoard)
				return Alert(title: Text("Reset game?"), primaryButton: confirmButton, secondaryButton: .cancel())
			})
			.onAppear(perform: self.resetBoard)
		}
	}
	
	// MARK: - METHODS
	func isNil(_ string: String?) -> Bool { return string == nil }
	
	func cardImageFrom(string: String??) -> Image
	{
		if let string = string {
			return cardImageFrom(string: string)
		} else {
			return Image(CardBox.emptySpot)
		}
	}
	
	func cardImageFrom(string: String?) -> Image
	{
		if string == nil {
			return Image(CardBox.emptySpot)
		} else {
			var string = string!
			string.removeLast()
			return Image(string)
		}
	}
	
	func cardImageFrom(string: String, emptyCheck: Bool) -> Image
	{
		if emptyCheck {
			return Image(CardBox.emptySpot)
		} else {
			var string = string
			string.removeLast()
			return Image(string)
		}
	}
	
	func findDestination(for card: String) -> CardLocation
	{
		var card = card
		card.removeFirst()
		
		if card.first == "a" { return .acePile}
		else if card.first == "2" || card.first == "3" || card.first == "4" {
			let rowIndex = Int(String(card.first!))! - 2
			let row = board[rowIndex]
			for stackIndex in 0..<row.count {
				if row[stackIndex].isEmpty { return .board(row: rowIndex, stack: stackIndex) }
			}
		} else {
			var cardToMatch: String
			var line: Int
			var stackSize: Int
			switch card.first {
				case "5":
					cardToMatch = "2"
					line = 0
					stackSize = 1
				case "8":
					cardToMatch = "5"
					line = 0
					stackSize = 2
				case "j":
					cardToMatch = "8"
					line = 0
					stackSize = 3
				case "6":
					cardToMatch = "3"
					line = 1
					stackSize = 1
				case "9":
					cardToMatch = "6"
					line = 1
					stackSize = 2
				case "q":
					cardToMatch = "9"
					line = 1
					stackSize = 3
				case "7":
					cardToMatch = "4"
					line = 2
					stackSize = 1
				case "1":
					cardToMatch = "7"
					line = 2
					stackSize = 2
				case "k":
					cardToMatch = "1" // 10
					line = 2
					stackSize = 3
				default:
					cardToMatch = ""
					line = 0
					stackSize = 0
			}
			
			let row = board[line]
			for stackIndex in 0..<row.count {
				if let possibleCard = row[stackIndex].last {
					assert(possibleCard != nil, "@findDestination possibleCard is nil.")
					var cardNumber = possibleCard!
					cardNumber.removeFirst()
					cardNumber = String(cardNumber.first!)
					if cardNumber == cardToMatch && row[stackIndex].count == stackSize
					{
						return .board(row: line, stack: stackIndex)
					}
				}
			}
		}
		
		return .none
	}
	
	func resetBoard()
	{
		gameWon = false
		
		board.removeAll(keepingCapacity: true)
		stockPile.removeAll(keepingCapacity: true)
		acePile.removeAll(keepingCapacity: true)
		dispensePile.removeAll(keepingCapacity: true)
		
		dispensePile.append(contentsOf: CardBox.getCardSet(from: .twoDecks))
		
		let main2 = CardBox.getRandomCard(from: dispensePile, numbered: "2")
		let main3 = CardBox.getRandomCard(from: dispensePile, numbered: "3")
		let main4 = CardBox.getRandomCard(from: dispensePile, numbered: "4")
		
		var idx = dispensePile.firstIndex(of: main2)!
		dispensePile.remove(at: idx)
		idx = dispensePile.firstIndex(of: main3)!
		dispensePile.remove(at: idx)
		idx = dispensePile.firstIndex(of: main4)!
		dispensePile.remove(at: idx)
		
		var line = [[String]]()
		line.append([main2])
		line.append(contentsOf: dispensePile[..<7].map { [$0] })
		dispensePile.removeSubrange(0..<7)
		board.append(line)
		
		line = [[String]]()
		line.append([main3])
		line.append(contentsOf: dispensePile[..<7].map { [$0] })
		dispensePile.removeSubrange(0..<7)
		board.append(line)
			
		line = [[String]]()
		line.append([main4])
		line.append(contentsOf: dispensePile[..<7].map { [$0] })
		dispensePile.removeSubrange(0..<7)
		board.append(line)
			
		line = [[String]]()
		line.append(contentsOf: dispensePile[..<8].map { [$0] })
		dispensePile.removeSubrange(0..<8)
		for i in 0..<line.count {
			stockPile.append(line[i])
		}
	}
	
	func checkForGameWin()
	{
		if dispensePile.isEmpty {
			for pile in stockPile {
				if !pile.isEmpty { return }
			}
			gameWon = true
			withAnimation
			{
				self.gameEndOpacity = 1.0
				self.gameEndScale = 1.0
			}
		}
	}
}

// MARK: - PREVIEWS
struct PlayingTable_Previews: PreviewProvider {
    static var previews: some View {
        PlayingTable()
    }
}
