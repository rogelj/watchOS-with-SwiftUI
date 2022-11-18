//
//  ContentView.swift
//  HelloAppleWatch Watch App
//
//  Created by J Rogel PhD on 18/11/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sentence = EmojiSentence()


    var body: some View {
        VStack {
            Image("Cookie")
                .resizable()
                .scaledToFit()
                // 1
                .overlay(
                    // 2
                    Text(sentence.emoji)
                    // 3
                        .font(.title3)
                        .padding(.top, 10)
                        .buttonStyle(.plain)
                )
            Text(sentence.text)
                .font(.caption)
                .padding(.top, 20)

        }
        .onTapGesture { sentence.next() }


    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
