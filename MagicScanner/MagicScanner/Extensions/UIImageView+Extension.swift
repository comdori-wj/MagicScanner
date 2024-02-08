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
        
        let sx = Double(self.frame.size.width / image.size.width)
        let sy = Double(self.frame.size.height / image.size.height)
        var s = 1.0
        switch (self.contentMode) {
        case .scaleAspectFit:
            s = fmin(sx, sy)
            return CGSize (width: s, height: s)
            
        case .scaleAspectFill:
            s = fmax(sx, sy)
            return CGSize(width:s, height:s)
            
        case .scaleToFill:
            return CGSize(width:sx, height:sy)
            
        default:
            return CGSize(width:s, height:s)
        }
    }
    
    var normalizedTransformForOrientation: CGAffineTransform? {
        
        guard let image = image else {
            return nil
        }
        
        let r: CGFloat
        
        switch image.imageOrientation {
            
        case .up:
            r = 0
            
        case .down:
            r = +1.5
            
        case .left:
            r = -0.5
            
        case .right:
            r = +0.5
            
        default:
            fatalError()
        }
        
        let cx = CGRectGetMidX(bounds)
        let cy = CGRectGetMidY(bounds)
        
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, cx, cy)
        transform = CGAffineTransformRotate(transform, .pi * r)
        transform = CGAffineTransformTranslate(transform, -cx, -cy)
        return transform
    }
}
