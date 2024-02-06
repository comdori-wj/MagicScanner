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
    
    func detecteRectangle(ciImage: CIImage) throws -> CIRectangleFeature {
        let rectanglesOptions = [CIDetectorAspectRatio: NSNumber(floatLiteral: 1.75)]
        let features = detector.features(in: ciImage, options: rectanglesOptions)
        guard let rectangleFeature = features.first as? CIRectangleFeature else { throw DetectorError.failToDetectRectangle }
        
        return rectangleFeature
    }
    
    func getPrepectiveImage(ciImage: CIImage, feature: CIRectangleFeature) throws -> CIImage? {
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
