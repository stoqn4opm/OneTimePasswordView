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
/// } onSubmit: { enteredCode, recognisedCallback in
///     // check if enteredCode is correct and pass true or false to `recognisedCallback`
///     // indicating whether it was recognised or not
///     recognisedCallback(true)
/// }
/// ```
public struct OneTimePasswordView<Placeholder>: View where Placeholder: View {
    
    /// Controls the corner radius of each individual "box". Default is 8.
    public let cornerRadius: CGFloat
    
    /// Controls how many digits should be entered by the user. Default is 4.
    public let digitCount: Int
    
    /// Controls the color of the character in the input boxes. Default is `UIColor.label`
    public let foregroundColor: Color
    
    /// Controls the color of the background of the input boxes. Default is `UIColor.systemGroupedBackground`
    public let backgroundColor: Color
    
    /// A set that determines which inputs from the user should be accepted and which should be ignored.
    /// Default is `.decimalDigits`
    public let allowedCharacterSet: CharacterSet
    
    /// A closure that is executed when the text input changes. You can check how many characters are allowed,
    /// by checking the value in `digitCount`.
    public let onChange: (([Character]) -> ())?
    
    /// A closure that gives you the ability to react to the user input, after all boxes are filled in.
    public let onSubmit: (_ enteredCharacters: [Character],
                          _ inputCorrectCallback: @escaping (_ inputIsCorrect: Bool) -> ()
    ) -> ()
    
    
    @State private var typedCharacters: [Character] = []
    @State private var isDisabled: Bool = false
    @State private var highlightBorderColor: Color
    @State private var borderColor: Color
    @State private var shouldShake = false
    
    private let pasteboardAccessor: () -> String?
    @FocusState private var internalFocus: Bool
    private var externalInputFieldFocus: FocusState<Bool>.Binding?
    private var effectiveFocus: FocusState<Bool>.Binding { externalInputFieldFocus ?? $internalFocus }
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
    /// } onSubmit: { enteredCode, recognisedCallback in
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
    ///     Default is `.decimalDigits`
    ///   - highlightBorderColor: Controls the color of the border for the highlighted input box. Default value is `UIColor.label`
    ///   - borderColor: Controls the color of the border for the non highlighted input boxes. Default value is `UIColor.systemGray4`
    ///   - pasteboardAccessor: provides a closure meant to return the pasteboard content
    ///   - inputFieldFocus: Gives you the ability to control the focus of this view (to become/resign being first responder).
    ///   - placeholder: View builder used to provide a placeholder appearance for when there is no
    ///     entered character by the user in an input box.
    ///   - onSubmit: A closure that gives you the ability to react to the user input, after all boxes are filled in.
    ///   - onChange: A closure that is executed when the text input changes. You can check how many characters are allowed,
    ///     by checking the value in `digitCount`.
    public init(cornerRadius: CGFloat =  8,
                digitCount: Int =  4,
                foregroundColor: Color = Color(uiColor: .label),
                backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                allowedCharacterSet: CharacterSet = .decimalDigits,
                highlightBorderColor: Color = Color(uiColor: .label),
                borderColor: Color = Color(uiColor: .systemGray4),
                pasteboardAccessor: @escaping () -> String? = { UIPasteboard.general.string },
                inputFieldFocus: FocusState<Bool>.Binding? = nil,
                @ViewBuilder placeholder: @escaping () -> Placeholder,
                onChange: (([Character]) -> ())? = nil,
                onSubmit: @escaping ([Character], @escaping (Bool) -> ()) -> ()) {
        
        self.cornerRadius = cornerRadius
        self.digitCount = digitCount
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.allowedCharacterSet = allowedCharacterSet
        self._highlightBorderColor = State(initialValue: highlightBorderColor)
        self._borderColor = State(initialValue: borderColor)
        self.pasteboardAccessor = pasteboardAccessor
        self.externalInputFieldFocus = inputFieldFocus
        self.onChange = onChange
        self.onSubmit = onSubmit
        self.placeholder = placeholder
    }
    
    /// Creates a SwiftUI view, meant to accept one time passwords sends to the user
    /// for authentication.
    ///
    /// It can be configured with a set with allowed characters and with
    /// characters count, as well as with a few UI tweaks, that you can inject
    /// from the constructor.
    ///
    /// Example usage:
    /// ```swift
    /// OneTimePasswordView(placeholder:
    ///     Circle()
    ///         .fill(Color.brown)
    ///         .padding()
    /// ) { enteredCode, recognisedCallback in
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
    ///     Default is `.decimalDigits`
    ///   - highlightBorderColor: Controls the color of the border for the highlighted input box. Default value is `UIColor.label`
    ///   - borderColor: Controls the color of the border for the non highlighted input boxes. Default value is `UIColor.systemGray4`
    ///   - pasteboardAccessor: provides a closure meant to return the pasteboard content
    ///   - inputFieldFocus: Gives you the ability to control the focus of this view (to become/resign being first responder).
    ///   - placeholder: Pass a View used to provide a placeholder appearance for when there is no
    ///     entered character by the user in an input box.
    ///   - onSubmit: A closure that gives you the ability to react to the user input, after all boxes are filled in.
    ///   - onChange: A closure that is executed when the text input changes. You can check how many characters are allowed,
    ///     by checking the value in `digitCount`.
    public init(cornerRadius: CGFloat =  8,
                digitCount: Int =  4,
                foregroundColor: Color = Color(uiColor: .label),
                backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                allowedCharacterSet: CharacterSet = .decimalDigits,
                highlightBorderColor: Color = Color(uiColor: .label),
                borderColor: Color = Color(uiColor: .systemGray4),
                pasteboardAccessor: @escaping () -> String? = { UIPasteboard.general.string },
                inputFieldFocus: FocusState<Bool>.Binding? = nil,
                placeholder: Placeholder,
                onChange: (([Character]) -> ())? = nil,
                onSubmit: @escaping ([Character], @escaping (Bool) -> ()) -> ()) {
        self.init(cornerRadius: cornerRadius,
                  digitCount: digitCount,
                  foregroundColor: foregroundColor,
                  backgroundColor: backgroundColor,
                  allowedCharacterSet: allowedCharacterSet,
                  highlightBorderColor: highlightBorderColor,
                  borderColor: borderColor,
                  pasteboardAccessor: pasteboardAccessor,
                  inputFieldFocus: inputFieldFocus,
                  placeholder: { placeholder },
                  onChange: onChange,
                  onSubmit: onSubmit)
    }
    
    public var body: some View {
        ZStack {
            inputGathering
                .focused(effectiveFocus)
            presentation
                .modifier(ShakeEffect(shakes: shouldShake ? 1 : 0))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1)
        .onTapGesture {
            effectiveFocus.wrappedValue = true
            typedCharacters = []
        }
        .padding(3)
        .contextMenu(menuItems: pasteContextMenu)
    }
}

// MARK: - Components

extension OneTimePasswordView {
    
    private var presentation: some View {
        PresentationView(
            cornerRadius: cornerRadius,
            digitCount: digitCount,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            highlightBorderColor: highlightBorderColor,
            inputFieldFocus: effectiveFocus.wrappedValue,
            borderColor: borderColor,
            placeholder: placeholder,
            typedCharacters: $typedCharacters)
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
            .frame(width: 1, height: 1)
            .onChange(of: characterBinding.wrappedValue) { newValue in
                onChange?(Array(newValue))
            }
    }
    
    @ViewBuilder private func pasteContextMenu() -> some View {
        if let raw = pasteboardAccessor(), raw.isEmpty == false {
            Button("Paste", systemImage: "document.on.clipboard.fill") {
                var input = String(raw)
                input.unicodeScalars.removeAll { scalar in
                    allowedCharacterSet.contains(scalar) == false
                }
                let trimmedChars = Array(input.prefix(digitCount))
                guard trimmedChars.isEmpty == false else { return }
                typedCharacters = trimmedChars
                submitCode()
            }
        }
    }
}

// MARK: - Actions

extension OneTimePasswordView {
    
    private func submitCode() {
        guard typedCharacters.count == digitCount else { return }
        isDisabled = true
        effectiveFocus.wrappedValue = false
        
        onSubmit(typedCharacters) { isSuccess in
            withAnimation {
                isDisabled = false
                guard isSuccess == false else { return }
                typedCharacters = []
                effectiveFocus.wrappedValue = true
                shouldShake.toggle()
            }
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
        } onSubmit: { enteredCode, recognisedCallback in
            recognisedCallback(true)
        }
    }
}

#endif

