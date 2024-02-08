//
//  Rectangle.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/6/24.
//

import CoreImage
final class Rectangle {
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint

    init(feature: CIRectangleFeature) {
        self.topLeft = feature.topLeft
        self.topRight = feature.topRight
        self.bottomRight = feature.bottomRight
        self.bottomLeft = feature.bottomLeft
    }
}
