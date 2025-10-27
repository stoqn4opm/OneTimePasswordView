//
//  ContentView.swift
//  OneTimePasswordViewExample
//
//  Created by Stoyan Stoyanov on 07/06/22.
//

import Foundation
import SwiftUI
import OneTimePasswordView

struct ContentView: View {
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                Spacer()
                OneTimePasswordView(digitCount: 5,
                                    placeholder: placeholderAppearance,
                                    onChange: charactersChanged(_:),
                                    onSubmit: recognise(_:_:))
                .frame(maxWidth: .infinity, maxHeight: (reader.size.width / 5) - 10, alignment: .center)
                .padding(.horizontal)
                Spacer()
            }
        }
    }
    
    @ViewBuilder func placeholderAppearance() -> AnyView {
        AnyView(
            Circle()
                .fill(Color(uiColor: .secondarySystemFill))
                .padding(28)
        )
    }
    
    private func charactersChanged(_ enteredCharacters: [Character]) {
        print("characters changed: \(enteredCharacters)")
    }
    
    private func recognise(_ enteredCharacters: [Character], _ inputCorrectCallback: @escaping (_ inputIsCorrect: Bool) -> ()) {
        
        // simulating an async check
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            inputCorrectCallback(false)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
