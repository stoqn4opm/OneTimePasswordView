//
//  PresentationView.swift
//  OneTimePasswordView
//
//  Created by stoyan on 23.10.25.
//

#if canImport(SwiftUI)

import SwiftUI

// MARK: - View Definition

struct PresentationView<Placeholder: View>: View {
    private let cornerRadius: CGFloat
    private let digitCount: Int
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let highlightBorderColor: Color
    private let inputFieldFocus: Bool
    @State private var borderColor: Color
    @ViewBuilder private var placeholder: () -> Placeholder
    @Binding private var typedCharacters: [Character]
    
    @State private var digitFrames: [Int: CGRect] = [:]
    
    init(cornerRadius: CGFloat,
         digitCount: Int,
         foregroundColor: Color,
         backgroundColor: Color,
         highlightBorderColor: Color,
         inputFieldFocus: Bool,
         borderColor: Color,
         placeholder: @escaping () -> Placeholder,
         typedCharacters: Binding<[Character]>) {
        self.cornerRadius = cornerRadius
        self.digitCount = digitCount
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.highlightBorderColor = highlightBorderColor
        self.inputFieldFocus = inputFieldFocus
        self.borderColor = borderColor
        self.placeholder = placeholder
        self._typedCharacters = typedCharacters
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            digitsView
            highlightView
        }
    }
}

// MARK: - Components

extension PresentationView {
    
    private var digitsView: some View {
        HStack {
            ForEach(0..<digitCount, id: \.self) { index in
                DigitView(
                    cornerRadius: cornerRadius,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor,
                    digit: character(for: index),
                    borderColor: $borderColor,
                    placeholder: placeholder
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: DigitFramePreferenceKey.self,
                            value: [index: proxy.frame(in: .named("otpSpace"))]
                        )
                    }
                )
                .animation(.bouncy, value: typedCharacters)
            }
        }
        .coordinateSpace(name: "otpSpace")
        .onPreferenceChange(DigitFramePreferenceKey.self) { frames in
            digitFrames = frames
        }
    }
    
    @ViewBuilder
    private var highlightView: some View {
        if inputFieldFocus, let frame = digitFrames[typedCharacters.indices.endIndex] {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(highlightBorderColor, lineWidth: 3)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)
                .animation(.bouncy, value: frame)
                .animation(.bouncy, value: typedCharacters)
        }
    }
}

// MARK: - Helpers

extension PresentationView {
    
    private func character(for index: Int) -> Binding<Character?> {
        guard typedCharacters.indices.contains(index) else { return .constant(nil) }
        let character = $typedCharacters[index]
        return Binding<Character?>(character)
    }
}

// MARK: - DigitFramePreferenceKey

extension PresentationView {
    
    /// Local-only preference key used to pass frames up to this view
    private struct DigitFramePreferenceKey: PreferenceKey {
        static var defaultValue: [Int : CGRect] { [:] }
        
        static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
            value.merge(nextValue()) { $1 }
        }
    }
}

#endif
