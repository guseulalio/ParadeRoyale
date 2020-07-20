//
//  ContentView.swift
//  ParadeRoyale
//
//  Created by Gustavo E M Cabral on 11/7/20.
//  Copyright © 2020 Gustavo Eulalio. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		NavigationView {
			ZStack {
				LinearGradient(gradient: Gradient(colors: [Color.green, Color.black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
				VStack {
					Text("Parade Royale Solitaire")
						.font(Font.custom("SnellRoundhand-Black", size: 32))
						.foregroundColor(.white)
						.padding()
					Spacer()
					
					NavigationLink(destination: PlayingTable().navigationBarTitle("")
						.navigationBarHidden(true)) {
						Text("Play")
							.padding(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)).background(Color.red).foregroundColor(.white).clipShape(Capsule())
					}
					Spacer()
				}
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView().previewLayout(.fixed(width: 896, height: 414))
	}
}
