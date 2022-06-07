//
//  OneTimePasswordView.swift
//  OneTimePasswordView
//
//  Created by Stoyan Stoyanov on 03/06/22.
//

#if canImport(UIKit) && canImport(SwiftUI)

import SwiftUI
import UIKit

// MARK: - OneTimePasswordView

/// A SwiftUI view, meant to accept one time passwords sends to the user
/// for authentication.
///
/// It can be configured with a set of allowed characters and with
/// characters count, as well as with a few UI tweaks, that you can inject
/// from the constructor.
/// Example usage:
/// ```swift
/// OneTimePasswordView {
///     Circle()
///         .fill(Color.brown)
///         .padding()
/// } passwordEnteredHandler: { enteredCode, recognisedCallback in
///     // check if enteredCode is correct and pass true or false to `recognisedCallback`
///     // indicating whether it was recognised or not
///     recognisedCallback(true)
/// }
/// ```
struct OneTimePasswordView<Placeholder>: View where Placeholder: View {
    
    /// Controls the corner radius of each individual "box". Default is 8.
    let cornerRadius: CGFloat
    
    /// Controls how many digits should be entered by the user. Default is 4.
    let digitCount: Int
    
    /// Controls the color of the character in the input boxes. Default is `UIColor.label`
    let foregroundColor: Color
    
    /// Controls the color of the background of the input boxes. Default is `UIColor.systemGroupedBackground`
    let backgroundColor: Color
    
    /// A set that determines which inputs from the user should be accepted and which should be ignored.
    /// Default is `.decimalDigits`
    let allowedCharacterSet: CharacterSet
    
    /// A closure that gives you the ability to react to the user input, after all boxes are filled in.
    let passwordEnteredHandler: (_ enteredCharacters: [Character],
                  _ inputCorrectCallback: @escaping (_ inputIsCorrect: Bool) -> ()
    ) -> ()
    
    
    @State private var typedCharacters: [Character] = []
    @State private var isDisabled: Bool = false
    @State private var highlightBorderColor: Color
    @State private var borderColor: Color
    @State private var shouldShake = false
    
    @FocusState private var inputFieldFocus: Bool
    
    @ViewBuilder private var placeholder: () -> Placeholder
    
    
    /// Creates a SwiftUI view, meant to accept one time passwords sends to the user
    /// for authentication.
    ///
    /// It can be configured with a set with allowed characters and with
    /// characters count, as well as with a few UI tweaks, that you can inject
    /// from the constructor.
    ///
    /// Example usage:
    /// ```swift
    /// OneTimePasswordView {
    ///     Circle()
    ///         .fill(Color.brown)
    ///         .padding()
    /// } passwordEnteredHandler: { enteredCode, recognisedCallback in
    ///     // check if enteredCode is correct and pass true or false to `recognisedCallback`
    ///     // indicating whether it was recognised or not
    ///     recognisedCallback(true)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cornerRadius: Controls the corner radius of each individual "box". Default is 8.
    ///   - digitCount: Controls how many digits should be entered by the user. Default is 4.
    ///   - foregroundColor: Controls the color of the character in the input boxes. Default is `UIColor.label`
    ///   - backgroundColor: Controls the color of the background of the input boxes. Default is `UIColor.systemGroupedBackground`
    ///   - allowedCharacterSet: A set that determines which inputs from the user should be accepted and which should be ignored.
    /// Default is `.decimalDigits`
    ///   - highlightBorderColor: Controls the color of the border for the highlighted input box. Default value is `UIColor.label`
    ///   - borderColor: Controls the color of the border for the non highlighted input boxes. Default value is `UIColor.systemGray4`
    ///   - placeholder: View builder used to provide a placeholder appearance for when there is no
    /// entered character by the user in an input box.
    ///   - passwordEnteredHandler: A closure that gives you the ability to react to the user input, after all boxes are filled in.
    init(cornerRadius: CGFloat =  8,
         digitCount: Int =  4,
         foregroundColor: Color = Color(uiColor: .label),
         backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
         allowedCharacterSet: CharacterSet = .decimalDigits,
         highlightBorderColor: Color = Color(uiColor: .label),
         borderColor: Color = Color(uiColor: .systemGray4),
         @ViewBuilder placeholder: @escaping () -> Placeholder,
         passwordEnteredHandler: @escaping ([Character], @escaping (Bool) -> ()) -> ()) {
        
        self.cornerRadius = cornerRadius
        self.digitCount = digitCount
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.allowedCharacterSet = allowedCharacterSet
        self._highlightBorderColor = State(initialValue: highlightBorderColor)
        self._borderColor = State(initialValue: borderColor)
        self.passwordEnteredHandler = passwordEnteredHandler
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            inputGathering
                .focused($inputFieldFocus)
            presentation
                .modifier(ShakeEffect(shakes: shouldShake ? 1 : 0))
        }
        .padding()
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1)
        .onTapGesture {
            inputFieldFocus = true
        }
    }
}

// MARK: - Components

extension OneTimePasswordView {
    
    private var presentation: some View {
        HStack {
            ForEach(0..<digitCount, id: \.self) { index in
                DigitView(cornerRadius: cornerRadius,
                          foregroundColor: foregroundColor,
                          backgroundColor: backgroundColor,
                          digit: character(for: index),
                          borderColor: borderColor(forDigitAtIndex: index),
                          placeholder: placeholder)
            }
        }
    }
    
    private var inputGathering: some View {
        let characterBinding = Binding<String> {
            String(typedCharacters)
        } set: { newValue in
            typedCharacters = Array(newValue)
            submitCode()
        }
        
        return TextField("", text: characterBinding)
            .onSubmit(submitCode)
            .onReceive(typedCharacters.publisher.collect()) { input in
                var input = String(input)
                input.unicodeScalars.removeAll { scalar in
                    allowedCharacterSet.contains(scalar) == false
                }
                
                let trimmedChars = Array(input.prefix(digitCount))
                if typedCharacters != trimmedChars {
                    typedCharacters = trimmedChars
                }
            }
            .accentColor(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
    }
}

// MARK: - Actions

extension OneTimePasswordView {
    
    private func submitCode() {
        guard typedCharacters.count == digitCount else { return }
        isDisabled = true
        inputFieldFocus = false
        
        passwordEnteredHandler(typedCharacters) { isSuccess in
            guard isSuccess == false else { return }
            withAnimation {
                typedCharacters = []
                isDisabled = false
                inputFieldFocus = true
                shouldShake.toggle()
            }
        }
    }
}

// MARK: - Helpers

extension OneTimePasswordView {
    
    private func character(for index: Int) -> Binding<Character?> {
        guard typedCharacters.indices.contains(index) else { return .constant(nil) }
        let character = $typedCharacters[index]
        return Binding<Character?>(character)
    }
    
    private func borderColor(forDigitAtIndex index: Int) -> Binding<Color> {
        if typedCharacters.indices.endIndex == index && inputFieldFocus {
            return $highlightBorderColor
        } else {
            return $borderColor
        }
    }
}

// MARK: - Previews

struct OneTimePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        OneTimePasswordView {
            Circle()
                .fill(Color.brown)
                .padding()
        } passwordEnteredHandler: { enteredCode, recognisedCallback in
            recognisedCallback(true)
        }
    }
}

#endif
