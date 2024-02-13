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
    private lazy var currentPhotoIndex = 0
    
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
        guard photos.count > 0 else { return print(PhotoManagerError.noPhoto) }
        
        currentPhotoIndex += 1
        if currentPhotoIndex >= photos.count {
            currentPhotoIndex = 0
        }
        imageView.image = photos[currentPhotoIndex]
        photoCount.text = "\(String(currentPhotoIndex + 1))/\(String(photos.count))"
        print("왼쪽 제스처")
    }
    
    @IBAction private func rightSwipeGesture(_ sender: Any) {
        guard photos.count > 0 else { return print(PhotoManagerError.noPhoto) }
        currentPhotoIndex -= 1
        if currentPhotoIndex < 0 {
            currentPhotoIndex = photos.count - 1
        }
        imageView.image = photos[currentPhotoIndex]
        
        photoCount.text = "\(String(currentPhotoIndex + 1))/\(String(photos.count))"
        print("오른쪽 제스처")
    }
    
    private func rotateImage(image: UIImage, byDegrees degrees: CGFloat) -> UIImage? {
        let oldSize = image.size
        let radianValue = abs(degrees) * CGFloat.pi / 180
        let newWidth = abs(oldSize.width * cos(radianValue)) + abs(oldSize.height * sin(radianValue))
        let newHeight = abs(oldSize.width * sin(radianValue)) + abs(oldSize.height * cos(radianValue))
        let newSize = CGSize(width: ceil(newWidth), height: ceil(newHeight))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: newSize.width / 2.0, y: newSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: -degrees * .pi / 180)
            image.draw(in: CGRect(x: -oldSize.width / 2, y: -oldSize.height / 2, width: oldSize.width, height: oldSize.height))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    @IBAction private func removePhotoButtonTapped(_ sender: Any) {
        if !photos.isEmpty {
            photos.remove(at: currentPhotoIndex)
            photoManager.originalPhotos.remove(at: currentPhotoIndex)
            
            if currentPhotoIndex > 0 {
                currentPhotoIndex -= 1
            }
        }
        
        if currentPhotoIndex < photos.count {
            imageView.image = photos[currentPhotoIndex]
        } else {
            guard let noImage = UIImage(systemName: "nosign") else { return }
            imageView.image = noImage
            print(PhotoManagerError.noPhoto)
        }
        imageView.contentMode = .scaleToFill
        
        print("사진들카운트: ", photos.count)
        photoCount.text = "\(String(currentPhotoIndex))/\(String(photos.count))"
        photoManager.perspectivePhotos = photos
    }
    
    @IBAction private func rotateButtonTapped(_ sender: Any) {
        if let image = imageView.image {
            imageView.image = rotateImage(image: image, byDegrees: 90)
            print("반시계로 회전됨")
        }
    }
    
    @IBAction private func cropButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let repointViewController = storyboard.instantiateViewController(withIdentifier: "RepointViewController") as? RepointViewController else { return }
        repointViewController.modalPresentationStyle = .fullScreen
        repointViewController.lastPhotoIndex = currentPhotoIndex
        print("넘어가는 카운트수: ",repointViewController.lastPhotoIndex,  currentPhotoIndex)
        navigationController?.pushViewController(repointViewController, animated: true)
    }
    
}
