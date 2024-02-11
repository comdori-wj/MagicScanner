//
//  PreViewController.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/8/24.
//

import UIKit

final class PreViewController: UIViewController {
    private let photoManager = PhotoManager.shared
    @IBOutlet weak var imageView: UIImageView!
    private lazy var photos = [UIImage]()
    @IBOutlet weak var photoCount: UILabel!
    private lazy var currentPhotoIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImageView(image: photoManager.getPhoto())
        photos = photoManager.perspectivePhotos
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func updateImageView(image: UIImage) {
        imageView?.image = image
        photoCount.text = "\(String(currentPhotoIndex + 1))/\(String(photos.count + 1))"
        let count = photoManager.perspectivePhotos.count
        print("프리뷰 인식된 사진 갯수 확인: ", count)
        
    }
    
    
    
    @IBAction private func leftSwipeGesture(_ sender: Any) {
        currentPhotoIndex += 1
        if currentPhotoIndex >= photos.count {
            currentPhotoIndex = 0
        }
        imageView.image = photos[currentPhotoIndex]
        photoCount.text = "\(String(currentPhotoIndex + 1))/\(String(photos.count))"
        print("왼쪽 제스처")
    }
    
    @IBAction private func rightSwipeGesture(_ sender: Any) {
        currentPhotoIndex -= 1
        if currentPhotoIndex < 0 {
            currentPhotoIndex = photos.count - 1
        }
        imageView.image = photos[currentPhotoIndex]
        photoCount.text = "\(String(currentPhotoIndex + 1))/\(String(photos.count))"
        print("오른쪽 제스처")
    }
    
    private func rotateImage(image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: image.size.width / 2.0, y: image.size.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: -degrees * .pi / 180)
            image.draw(in: CGRect(x: -origin.x, y: -origin.y, width: image.size.width, height: image.size.height))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    @IBAction private func rotateButtonTapped(_ sender: Any) {
        if let image = imageView.image {
            imageView.image = rotateImage(image: image, byDegrees: 90)
            print("반시계로 회전됨")
        }
    }
}
