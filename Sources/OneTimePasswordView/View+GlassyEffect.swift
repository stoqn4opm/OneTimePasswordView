//
//  View+GlassyEffect.swift
//  OneTimePasswordView
//
//  Created by stoyan on 28.10.25.
//


import SwiftUI

// MARK: - Glass Effect Replica

/*
 This file defines a custom view modifier `glassyEffect()`, modeled after the
 `.glassEffect()` modifier introduced in iOS 26. It provides a deep replica of
 the original API: on iOS 26 and newer it forwards directly to SwiftUI’s native
 implementation, while on older versions it falls back to rendering a tinted
 shape overlay with the same API surface.
 
 This allows you to reuse the same knowledge and syntax of `.glassEffect()` in
 an iOS 15 project while still achieving liquid glass–like visuals.
 */

extension Color {
    /// Returns `self` on iOS 26 and later, otherwise returns the provided fallback color.
    ///
    /// This helper supports pre-iOS 26 builds where the native Liquid Glass tinting
    /// isn’t available. When running on iOS 26 or newer, the color instance you call
    /// this on is preserved. On older systems, the supplied `color` parameter is used
    /// instead so you can approximate the intended appearance.
    ///
    /// - Parameter color: The fallback tint to use on platforms earlier than iOS 26.
    /// - Returns: `self` on iOS 26 and later; otherwise the `color` fallback.
    ///
    /// - Discussion: Use this when specifying tints that should defer to the system’s
    /// Liquid Glass behavior on newer OS versions but need a sensible, legible tint on
    /// earlier versions. It helps keep your color choices centralized without scattering
    /// availability checks throughout your UI code.
    ///
    /// - Example:
    /// ```swift
    /// let tint = Color.blue.preLiquidGlassFallback(.secondary)
    /// ```
    func preLiquidGlassFallback(_ color: Color) -> Color {
        if #available(iOS 26, *) {
            return self
        } else {
            return color
        }
    }
}

extension View {
    
    /// Applies a glass effect to this view.
    ///
    /// When you use a glass effect, the platform:
    ///   - Renders a shape anchored behind this view filled with
    ///     the physical glass material
    ///   - Applies the foreground effects of the glass over this view.
    ///
    /// For example, you could add a glass effect to a ``Label``:
    ///
    ///     Label("Flag", systemImage: "flag.fill")
    ///         .padding()
    ///         .glassEffect()
    ///
    /// SwiftUI uses the ``Glass/regular`` variant by default along with
    /// a ``Capsule`` shape.
    ///
    /// SwiftUI anchors the glass to the view's bounds. For the example
    /// above, the physical glass material fills the entirety of the label's
    /// frame, which includes the padding.
    ///
    /// You typically use this modifier with a ``GlassEffectContainer``
    /// to combine multiple glass shapes into a single shape that
    /// can morph shapes into one another.
    @ViewBuilder
    func glassyEffect(_ glass: Glass = .regular, in shape: some Shape) -> some View {
        glassyEffect(glass, in: shape) { view in
            view
                .background {
                    shape
                        .fill(glass.tintColor ?? .secondary)
                }
                .contentShape(shape)
            
        }
    }
    
    /// Applies a glass effect to this view.
    ///
    /// When you use a glass effect, the platform:
    ///   - Renders a shape anchored behind this view filled with
    ///     the physical glass material
    ///   - Applies the foreground effects of the glass over this view.
    ///
    /// For example, you could add a glass effect to a ``Label``:
    ///
    ///     Label("Flag", systemImage: "flag.fill")
    ///         .padding()
    ///         .glassEffect()
    ///
    /// SwiftUI uses the ``Glass/regular`` variant by default along with
    /// a ``Capsule`` shape.
    ///
    /// SwiftUI anchors the glass to the view's bounds. For the example
    /// above, the physical glass material fills the entirety of the label's
    /// frame, which includes the padding.
    ///
    /// You typically use this modifier with a ``GlassEffectContainer``
    /// to combine multiple glass shapes into a single shape that
    /// can morph shapes into one another.
    @ViewBuilder
    func glassyEffect(_ glass: Glass = .regular) -> some View {
        glassyEffect(glass) { view in
            view.glassyEffect(glass, in: Capsule())
        }
    }
    
    /// Applies a glass effect to this view with a specified shape and a fallback view builder.
    ///
    /// This version allows specifying a fallback view builder to be used on platforms
    /// earlier than iOS 26 where the native `glassEffect` modifier is unavailable.
    ///
    /// - Parameters:
    ///   - glass: The glass style to apply. Defaults to `.regular`.
    ///   - shape: The shape to use for the glass effect.
    ///   - fallback: A view builder that produces the fallback view for pre–iOS 26.
    /// - Returns: A view with the glass effect applied on iOS 26 and newer, or the fallback view otherwise.
    ///
    /// - Discussion: Use this overload when you want to provide a custom fallback rendering
    /// for older OS versions while using the native glass effect on iOS 26 and newer.
    ///
    /// - Example:
    /// ```swift
    /// Label("Flag", systemImage: "flag.fill")
    ///   .padding()
    ///   .glassyEffect(.regular, in: Capsule()) {
    ///       Capsule().fill(Color.gray.opacity(0.25))
    ///   }
    /// ```
    @ViewBuilder
    func glassyEffect(
        _ glass: Glass = .regular,
        in shape: some Shape,
        @ViewBuilder or fallback: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(glass.nativeGlassType, in: shape)
        } else {
            fallback(self)
        }
    }
    
    /// Applies a glass effect to this view with a fallback view.
    ///
    /// This overload allows providing a fallback view to be used on platforms
    /// where the native `glassEffect` modifier is unavailable (pre-iOS 26).
    ///
    /// - Parameters:
    ///   - glass: The glass style to apply. Defaults to `.regular`.
    ///   - fallback: A view builder that produces the fallback view.
    /// - Returns: A view with the glass effect applied on iOS 26 and newer, or the fallback view otherwise.
    ///
    /// - Discussion: Use this method when you want to provide a custom fallback rendering
    /// for older OS versions while using the native glass effect on iOS 26 and newer.
    ///
    /// - Example:
    /// ```swift
    /// Label("Flag", systemImage: "flag.fill")
    ///   .padding()
    ///   .glassyEffect(.regular) {
    ///       Capsule().fill(Color.gray.opacity(0.25))
    ///   }
    /// ```
    @ViewBuilder
    func glassyEffect(
        _ glass: Glass = .regular,
        @ViewBuilder or fallback: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(glass.nativeGlassType)
        } else {
            fallback(self)
        }
    }
}

fileprivate struct DefaultGlassEffectShapeMarker: Shape {
    func path(in rect: CGRect) -> Path { .init() }
}

// MARK: - Deep Interface Extraction

final class Glass {
    
    private enum GlassType {
        case regular
        case clear
        case identity
    }
    
    /// The regular variant of glass.
    ///
    /// The regular variant of glass automatically maintains legibility
    /// of content by adjusting its content based on the luminosity of the
    ///  content beneath the glass.
    static var regular: Glass { .init(glassType: .regular) }
    
    /// The clear variant of glass.
    ///
    /// When using clear glass, ensure content remains legible by adding a
    /// dimming layer or other treatment beneath the glass.
    ///
    /// For example, you could add a transparent black color beneath your
    /// glass to ensure content remains legible above the glass.
    ///
    ///     Label("Flag", systemImage: "flag.fill")
    ///         .padding()
    ///         .glassEffect(.clear)
    ///         .background(.black.opacity(0.3))
    ///
    static var clear: Glass { .init(glassType: .clear) }
    
    /// The identity variant of glass. When applied, your content
    /// remains unaffected as if no glass effect was applied.
    static var identity: Glass { .init(glassType: .identity) }
    
    /// Returns a copy of the glass with the provided tint color.
    func tint(_ color: Color?) -> Glass {
        tintColor = color
        return self
    }
    
    /// Returns a copy of the glass configured to be interactive.
    func interactive(_ isEnabled: Bool = true) -> Glass {
        isInteractive = isEnabled
        return self
    }
    
    private let glassType: GlassType
    fileprivate var tintColor: Color? = nil
    private var isInteractive: Bool? = nil
    
    private init(glassType: GlassType) {
        self.glassType = glassType
    }
    
    @available(iOS 26.0, *)
    fileprivate var nativeGlassType: SwiftUI.Glass {
        var result: SwiftUI.Glass = switch glassType {
        case .regular: .regular
        case .clear: .clear
        case .identity: .identity
        }
        
        if let tintColor {
            result = result.tint(tintColor)
        }
        
        if let isInteractive {
            result = result.interactive(isInteractive)
        }
        
        return result
    }
}
