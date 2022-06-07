//
//  DigitView.swift
//  OneTimePasswordView
//
//  Created by Stoyan Stoyanov on 03/06/22.
//

#if canImport(SwiftUI)

import SwiftUI

// MARK: - Digit View

/// A view that represents a single input box from our `OneTimePasswordView`.
struct DigitView<Placeholder>: View where Placeholder: View {
    
    /// Controls the corner radius of the view.
    let cornerRadius: CGFloat
    
    /// Color used for the user typed text in the box.
    let foregroundColor: Color
    
    /// Color used for the background of the box. Placeholders,
    /// could provide another color on top of this one leaving it hidden.
    let backgroundColor: Color
    
    /// Controls the width of the border surrounding the view.
    /// For adjusting the colors on the border, see `borderColor`.
    let borderWidth: CGFloat
    
    /// Contains the entered digit by the user, that should appear in this box.
    @Binding var digit: Character?
    
    /// Controls the color of the border of this digit view.
    /// It is a binding, because `OneTimePasswordView` changes this color
    /// to indicate which is the current digit view in which the user needs to type.
    @Binding var borderColor: Color
    
    /// View builder used to provide a placeholder appearance for when there is no
    /// entered character by the user.
    @ViewBuilder var placeholder: () -> Placeholder
    
    /// A view that represents a single input box from our `OneTimePasswordView`.
    ///
    /// - Parameters:
    ///   - cornerRadius: Controls the corner radius of the view.
    ///   - foregroundColor: Color used for the user typed text in the box.
    ///   - backgroundColor: Color used for the background of the box. Placeholders,
    /// could provide another color on top of this one leaving it hidden.
    ///   - digit: Contains the entered digit by the user, that should appear in this box.
    ///   - borderColor: Controls the color of the border of this digit view.
    /// It is a binding, because `OneTimePasswordView` changes this color
    /// to indicate which is the current digit view in which the user needs to type.
    ///   - borderWidth: Controls the width of the border surrounding the view.
    /// For adjusting the colors on the border, see `borderColor`.
    ///   - placeholder: View builder used to provide a placeholder appearance for when there is no
    /// entered character by the user.
    init(cornerRadius: CGFloat,
         foregroundColor: Color,
         backgroundColor: Color,
         digit: Binding<Character?>,
         borderColor: Binding<Color>,
         borderWidth: CGFloat = 2,
         @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.cornerRadius = cornerRadius
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self._digit = digit
        self._borderColor = borderColor
        self.borderWidth = borderWidth
        self.placeholder = placeholder
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(borderColor, lineWidth: borderWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(alignment: .center) {
                if let digit = digit {
                    Text(String(digit))
                        .foregroundColor(foregroundColor)
                } else {
                    placeholder()
                }
            }
    }
}

// MARK: - Preview

struct DigitView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DigitView(cornerRadius: 8, foregroundColor: .red, backgroundColor: .blue, digit: .constant("2"), borderColor: .constant(.green)) {
                EmptyView()
            }
            .frame(width: 40, height: 60, alignment: .center)
            
            DigitView(cornerRadius: 8, foregroundColor: .red, backgroundColor: .blue, digit: .constant(nil), borderColor: .constant(.green)) {
                Circle()
                    .fill(Color.brown)
                    .padding()
            }
        }
        .frame(width: 40, height: 60, alignment: .center)
    }
}

#endif
