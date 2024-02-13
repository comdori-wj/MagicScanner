//
//  UIImageView+Extension.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/8/24.
//

import UIKit

extension UIImageView {
    var imageScale: CGSize? {
        guard let image = image else {
            return nil
        }
        let aspectRatioWidth = Double(self.frame.size.width / image.size.width)
        let aspectRatioHeight = Double(self.frame.size.height / image.size.height)
        var scalingFactor = 1.0
        
        switch (self.contentMode) {
        case .scaleAspectFit:
            scalingFactor = fmin(aspectRatioWidth, aspectRatioHeight)
            return CGSize (width: scalingFactor, height: scalingFactor)
        case .scaleAspectFill:
            scalingFactor = fmax(aspectRatioWidth, aspectRatioHeight)
            return CGSize(width:scalingFactor, height:scalingFactor)
        case .scaleToFill:
            return CGSize(width:aspectRatioWidth, height:aspectRatioHeight)
        default:
            return CGSize(width:scalingFactor, height:scalingFactor)
        }
    }
    
    var normalizedTransformForOrientation: CGAffineTransform? {
        guard let image = image else {
            return nil
        }
        let rotationAngle: CGFloat
        
        switch image.imageOrientation {
        case .up:
            rotationAngle = 0
        case .down:
            rotationAngle = +1.5
        case .left:
            rotationAngle = -0.5
        case .right:
            rotationAngle = +0.5
        default:
            fatalError()
        }
        
        let centerX = CGRectGetMidX(bounds)
        let centerY = CGRectGetMidY(bounds)
        var transform = CGAffineTransformIdentity
        
        transform = CGAffineTransformTranslate(transform, centerX, centerY)
        transform = CGAffineTransformRotate(transform, .pi * rotationAngle)
        transform = CGAffineTransformTranslate(transform, -centerX, -centerY)
        return transform
    }
}
