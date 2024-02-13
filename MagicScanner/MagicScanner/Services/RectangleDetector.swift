//
//  RectangleDetector.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/5/24.
//

import CoreImage

final class RectangleDetector {
    
    private let detector: CIDetector = {
        let detectorOptions: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorMinFeatureSize: Float(0.2)]
        guard let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: detectorOptions) else {
            return CIDetector()
        }
        
        return detector
    }()
    
    func detecteRectangle(ciImage: CIImage) throws -> Rectangle {
        let rectanglesOptions = [CIDetectorAspectRatio: NSNumber(floatLiteral: 1.75)]
        let features = detector.features(in: ciImage, options: rectanglesOptions)
        guard let rectangleFeatures = features as? [CIRectangleFeature] else { throw DetectorError.failToDetectRectangle }
        
        guard !rectangleFeatures.isEmpty else { throw DetectorError.failToDetectRectangle }
        
        var maxPerimeter: CGFloat = 0
        var largestRectangle: CIRectangleFeature = rectangleFeatures[0]
        
        for rectangleFeature in rectangleFeatures {
            let point1 = rectangleFeature.topLeft
            let point2 = rectangleFeature.topRight
            let width = hypotf(Float(point1.x - point2.x), Float(point1.y - point2.y))
            
            let point3 = rectangleFeature.topLeft
            let point4 = rectangleFeature.bottomLeft
            let height = hypotf(Float(point3.x - point4.x), Float(point3.y - point4.y))
            
            let currentPerimeter = CGFloat(width + height)
            
            if currentPerimeter > maxPerimeter {
                maxPerimeter = currentPerimeter
                largestRectangle = rectangleFeature
            }
        }

        let rectangleFeature: CIRectangleFeature? = largestRectangle
        if rectangleFeature == nil {
            throw DetectorError.failToDetectRectangle
        }

        var points = [
            rectangleFeature?.topLeft,
            rectangleFeature?.topRight,
            rectangleFeature?.bottomLeft,
            rectangleFeature?.bottomRight
        ]
        
        var minimum = points[0]
        var maximum = points[0]
        for point in points {
            let minx = min((minimum?.x)!, (point?.x)!)
            let miny = min((minimum?.y)!, (point?.y)!)
            let maxx = max((maximum?.x)!, (point?.x)!)
            let maxy = max((maximum?.y)!, (point?.y)!)
            minimum?.x = minx
            minimum?.y = miny
            maximum?.x = maxx
            maximum?.y = maxy
        }
        let center = CGPoint(x: ((minimum?.x)! + (maximum?.x)!) / 2, y: ((minimum?.y)! + (maximum?.y)!) / 2)
        let angle = { (point: CGPoint) -> CGFloat in
            let theta = atan2(point.y - center.y, point.x - center.x)
            return fmod(.pi * 3.0 / 4.0 + theta, 2 * .pi)
        }
        points.sort{angle($0!) < angle($1!)}
        let rectangleFeatureMutable = Rectangle(feature: largestRectangle)
        rectangleFeatureMutable.bottomLeft = points[0]!
        rectangleFeatureMutable.bottomRight = points[1]!
        rectangleFeatureMutable.topRight = points[2]!
        rectangleFeatureMutable.topLeft = points[3]!
        return rectangleFeatureMutable
    }
    
    func getPrepectiveImage(ciImage: CIImage, feature: Rectangle) throws -> CIImage? {
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection?.outputImage else { throw DetectorError.failToGetPerspectiveCorrectionImage }
        return outputImage
    }
}
