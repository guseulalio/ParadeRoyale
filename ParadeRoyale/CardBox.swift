//
//  CardBox.swift
//  ParadeRoyale
//
//  Created by Gustavo E M Cabral on 15/7/20.
//  Copyright © 2020 Gustavo Eulalio. All rights reserved.
//

import Foundation

enum CardBox
{
	/***
	Represents the number of jokers to be used in the card deck.
	*/
	enum NumberOfJokers
	{ case noJoker, oneJoker, twoJokers }
	
	enum NumberOfDecks: Equatable
	{
		case oneDeck, twoDecks, fourDecks, manyDecks(quantity: Int)
		
		func asInt() -> Int
		{
			switch self
			{
			case .oneDeck: return 1
			case .twoDecks: return 2
			case .fourDecks: return 4
			case .manyDecks(let quantity): return quantity
			}
		}
	}
	
	static let emptySpot = "_empty-spot"
	static let cardBack = "_back-blue" // "_back-red"
	static let joker = "_joker"
	static let baralho = ["ca", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10", "cj", "cq", "ck",
						  "da", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "d10", "dj", "dq", "dk",
						  "ha", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9", "h10", "hj", "hq", "hk",
						  "sa", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "sj", "sq", "sk"]
	
	static func getCardSet(from numberOfDecks: NumberOfDecks = .oneDeck, with nJokers: NumberOfJokers = .noJoker) -> [String]
	{
		var cardSet: [String] = []
		
		let quantity = numberOfDecks.asInt()
		if quantity == 1 {
			cardSet = baralho
		} else if quantity > 1 {
			for i in 0..<quantity {
				cardSet.append(contentsOf: baralho.map({ $0 + "\(i + 1)" }))
			}
		}
		
		switch nJokers {
		case .noJoker: break
		case .oneJoker:
			cardSet.append(joker)
		case .twoJokers:
			cardSet.append(joker)
			cardSet.append(joker)
		}

		return cardSet.shuffled()
	}
	
	static func getRandomCard(from deck: [String], numbered number: String) -> String
	{
		let cards = deck.filter({
			let secondDigit = Array($0)[1]
			return String(secondDigit) == number
		})
		return cards.randomElement() ?? joker
	}
}
