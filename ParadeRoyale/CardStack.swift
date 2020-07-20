//
//  CardStack.swift
//  ParadeRoyale
//
//  Created by Gustavo E M Cabral on 15/7/20.
//  Copyright © 2020 Gustavo Eulalio. All rights reserved.
//

import SwiftUI

struct CardStack: View {
	@State private var stack = [String]()
	
	var topCard: String? {
		stack.isEmpty ? nil : stack[stack.count - 1]
	}
	
    var body: some View {
		ZStack {
			if stack.isEmpty {
				Image(CardBox.emptySpot).resizable().scaledToFit().frame(width: 40)
			} else if stack.count == 1 {
				Image(CardBox.emptySpot).resizable().scaledToFit().frame(width: 40)
			} else if stack.count > 1 {
				Image(CardBox.cardBack).resizable().scaledToFit().frame(width: 40)
			}
			if !stack.isEmpty {
				Image(stack[stack.count - 1]).resizable().scaledToFit().frame(width: 40).offset(CGSize(width: 0, height: -5))
			}
		}
    }
	
	func removeTopCard() -> String
	{ return stack.removeLast() }
	
	func isEmpty() -> Bool
	{ return stack.isEmpty }
}

struct CardStack_Previews: PreviewProvider {
    static var previews: some View {
        CardStack()
    }
}
