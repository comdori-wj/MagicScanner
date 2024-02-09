//
//  ImageManager.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2024/02/10.
//

import UIKit

final class PhotoManager {
    static let shared = PhotoManager()
    var originalPhotos: [UIImage] = []
//    var perspectivePhotos: [UIImage] = []
    
    func getPhoto(image: UIImage) throws {
        originalPhotos.append(image)
        print("사진 갯수: ", originalPhotos.count)
    }
    
    func onePhoto() -> UIImage {
        guard let image = originalPhotos.last else {
            print("no photo")
            return UIImage() }
        return image
    }
}
