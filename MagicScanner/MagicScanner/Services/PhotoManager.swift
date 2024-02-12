//
//  ImageManager.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2024/02/10.
//

import UIKit

final class PhotoManager {
    static let shared = PhotoManager()
    private let rectangleDetector = RectangleDetector()
    var originalPhotos: [UIImage] = []
    var perspectivePhotos: [UIImage] = []
    
    func setPhoto(image: UIImage) throws {
        originalPhotos.append(image)
        print("원본이미지 갯수: ", originalPhotos.count)
        let rectangleDetectorImage = try imageToDetectorRectangle(image: image)
        let perspectivePhoto = try convertCIImageToUIImage(ciImage: rectangleDetectorImage)
        perspectivePhotos.append(perspectivePhoto)
        print("인식된 사진 갯수: ", perspectivePhotos.count)
        
    }
    
    func getPhoto() -> UIImage {
        guard let image = perspectivePhotos.first else {
            print(PhotoManagerError.noPhoto)
            return UIImage() }
        return image
        
    }
    
    private func imageToDetectorRectangle(image: UIImage) throws -> CIImage {
        guard let ciImage = image.ciImage else { throw PhotoManagerError.convertToCIImageError }
        let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
        guard let outputRectangleImage = try rectangleDetector.getPrepectiveImage(ciImage: ciImage, feature: rectangleFeature) else { throw PhotoManagerError.failToOutputRectangleImage }
        return outputRectangleImage
    }
    
    
    private func convertCIImageToUIImage(ciImage: CIImage) throws -> UIImage {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw PhotoManagerError.failToCreateCGImage
        }
        return UIImage(cgImage: cgImage)
    }
}
