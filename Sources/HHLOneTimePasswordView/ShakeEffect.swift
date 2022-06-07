//
//  ShakeEffect.swift
//  OneTimePasswordView
//
//  Created by Stoyan Stoyanov on 06/06/22.
//

#if canImport(SwiftUI)

import Foundation
import SwiftUI

// MARK: - Shake Effect

/// A geometry effect that mimics what Apple password fields do when password is wrong.
struct ShakeEffect: GeometryEffect {
    
    /// The horizontal distance at which the "shaked" view should be moved
    let offset: CGFloat
    
    /// The speed at which the "shaked" view should be moved
    let speed: CGFloat
    
    var animatableData: CGFloat
    
    /// Creates a new geometry shake effect, that mimics the shake the Apple password fields do
    /// when the entered password is wrong.
    ///
    /// - Parameters:
    ///   - shakes: The number of shakes that you want performed. Default value is 1.
    ///   - offset: The horizontal distance at which the "shaked" view should be moved
    ///   - speed: The speed at which the "shaked" view should be moved
    init(shakes: Int = 1, offset: CGFloat = 6, speed: CGFloat = 4) {
        animatableData = CGFloat(shakes)
        self.offset = offset
        self.speed = speed
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: offset * sin(animatableData * speed * .pi), y: 0))
    }
}

#endif
