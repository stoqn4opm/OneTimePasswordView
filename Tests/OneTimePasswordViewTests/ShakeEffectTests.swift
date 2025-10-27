//
//  ShakeEffectTests.swift
//  OneTimePasswordView
//
//  Created by Stoyan Stoyanov on 07/06/22.
//

import XCTest
import SwiftUI
import CoreGraphics
@testable import OneTimePasswordView

final class ShakeEffectTests: XCTestCase {
    
    func testThatProjectionTransformIsCalculatedCorrectly() {
        
        let shakes = 3
        let offset: CGFloat = 10
        let speed: CGFloat = 4
        let shakeEffect = ShakeEffect(shakes: shakes, offset: offset, speed: speed)
        
        let result = shakeEffect.effectValue(size: .zero)
        
        let expectedResult = ProjectionTransform(CGAffineTransform(translationX: offset * sin(CGFloat(shakes) * speed * .pi), y: 0))
        XCTAssertEqual(result, expectedResult)
    }
}
