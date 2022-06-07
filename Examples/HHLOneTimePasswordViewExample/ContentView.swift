//
//  ContentView.swift
//  HHLOneTimePasswordViewExample
//
//  Created by Stoyan Stoyanov on 07/06/22.
//

import Foundation
import SwiftUI
import HHLOneTimePasswordView

struct ContentView: View {
    
    var body: some View {
        OneTimePasswordView(placeholder: placeholderAppearance,
                            passwordEnteredHandler: recognise)
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
    }
    
    @ViewBuilder func placeholderAppearance() -> AnyView {
        AnyView(
            Circle()
                .fill(Color(uiColor: .secondarySystemFill))
                .padding(28)
        )
    }
    
    func recognise(_ enteredCharacters: [Character], _ inputCorrectCallback: @escaping (_ inputIsCorrect: Bool) -> ()) {
        
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
