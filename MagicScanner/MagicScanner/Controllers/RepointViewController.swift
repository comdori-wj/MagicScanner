//
//  RepointViewController.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2024/02/12.
//

import UIKit
import AVFoundation

final class RepointViewController: UIViewController {
    private let rectangleDetector = RectangleDetector()
    private let photoManager = PhotoManager.shared
    lazy var lastPhotoIndex = 0
    
    @IBOutlet weak var imageView: UIImageView!
    private var rectangleLayer = CAShapeLayer()
    private var topLeftView: UIView?
    private var topRightView: UIView?
    private var bottomLeftView: UIView?
    private var bottomRightView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        let image = photoManager.originalPhotos[lastPhotoIndex]
        updateImageView(image: image)
    }
    
    private func updateImageView(image: UIImage) {
        imageView?.image = image
        let count = photoManager.originalPhotos.count
        print("현재 사진 번호 : ", lastPhotoIndex)
        print("원본 사진 갯수: ", count)
        rectangleMaker(image: image)
    }
    
    private func rectangleMaker(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0),
              let ciImage = CIImage(data: imageData) else {
            print(PhotoManagerError.convertToCIImageError)
            return
        }
        do {
            let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
            drawRectangle(forImage: ciImage, topLeft: rectangleFeature.topLeft, topRight: rectangleFeature.topRight, bottomLeft: rectangleFeature.bottomLeft, bottomRight: rectangleFeature.bottomRight)
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func transformForImageView(imageView: UIImageView) -> CGAffineTransform {
        
        guard let image = imageView.image else {
            return CGAffineTransformIdentity
        }
        
        guard let imageScale = imageView.imageScale else {
            return CGAffineTransformIdentity
        }
        
        guard let imageTransform = imageView.normalizedTransformForOrientation else {
            return CGAffineTransformIdentity
        }
        
        let frame = imageView.frame
        
        let imageWidth = image.size.width * imageScale.width
        let imageHeight = image.size.height * imageScale.height
        
        var transform = CGAffineTransformIdentity
        
        // Rotate to match the image orientation.
        transform = CGAffineTransformConcat(imageTransform, transform)
        
        // Flip vertically (flipped in CIDetector).
        transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(frame))
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        
        // Centre align.
        let tx: CGFloat = (CGRectGetWidth(frame) - imageWidth) / 0.5
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) / 2.0 - 80
        transform = CGAffineTransformTranslate(transform, tx, ty)
        
        // Scale to match UIImageView scaling.
        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)
        
        return transform
    }
    
    private func drawRectangle(forImage image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        
        // 이미지와 이미지 뷰의 비율을 계산합니다.
        let imageRect = AVMakeRect(aspectRatio: image.extent.size, insideRect: imageView.bounds)
        
        let imageView = UIImageView(frame: imageRect)
        imageView.image = UIImage(ciImage: image)
        
        let transform = transformForImageView(imageView: imageView)
        
        // 각 꼭지점을 변환합니다.
        let transformedTopLeft = topLeft.applying(transform)
        let transformedTopRight = topRight.applying(transform)
        let transformedBottomLeft = bottomLeft.applying(transform)
        let transformedBottomRight = bottomRight.applying(transform)
        
        // 변환된 꼭지점을 사용하여 사각형을 그립니다.
        let path = UIBezierPath()
        path.move(to: transformedTopLeft)
        path.addLine(to: transformedTopRight)
        path.addLine(to: transformedBottomRight)
        path.addLine(to: transformedBottomLeft)
        path.close()
        
        rectangleLayer.path = path.cgPath
        rectangleLayer.fillColor = UIColor.clear.cgColor
        rectangleLayer.strokeColor = UIColor(red: 79/255, green: 84/255, blue: 125/255, alpha: 1).cgColor
        rectangleLayer.lineWidth = 5
        
        self.imageView.layer.addSublayer(rectangleLayer)
        
        drawCircle(at: transformedTopLeft, position: "topLeft")
        drawCircle(at: transformedTopRight, position: "topRight")
        drawCircle(at: transformedBottomLeft, position: "bottomLeft")
        drawCircle(at: transformedBottomRight, position: "bottomRight")
    }
    
    private func drawCircle(at point: CGPoint, position: String) {
        let radius = CGFloat(13)
        let circleView = UIView(frame: CGRect(x: point.x - radius, y: point.y - radius, width: 2 * radius, height: 2 * radius))
        circleView.backgroundColor = UIColor(red: 66/255, green: 171/255, blue: 225/255, alpha: 0.5)
        circleView.layer.cornerRadius = radius
        circleView.isUserInteractionEnabled = true
        
        imageView.addSubview(circleView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        circleView.addGestureRecognizer(panGesture)
        
        switch position {
        case "topLeft":
            topLeftView = circleView
        case "topRight":
            topRightView = circleView
        case "bottomLeft":
            bottomLeftView = circleView
        case "bottomRight":
            bottomRightView = circleView
        default:
            break
        }
    }
    
    private func repointDrawRectangle(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        // 기존에 그려진 사각형을 삭제합니다.
        imageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 새로운 사각형을 그립니다.
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 79/255, green: 84/255, blue: 125/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 5
        
        imageView.layer.addSublayer(shapeLayer)
        
        drawCircle(at: topLeft, position: "topLeft")
        drawCircle(at: topRight, position: "topRight")
        drawCircle(at: bottomLeft, position: "bottomLeft")
        drawCircle(at: bottomRight, position: "bottomRight")
    }
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if let circleView = gesture.view {
            circleView.center = CGPoint(x: circleView.center.x + translation.x, y: circleView.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: view)
        
        if gesture.state == .ended {
            if let topLeftView = topLeftView,
               let topRightView = topRightView,
               let bottomLeftView = bottomLeftView,
               let bottomRightView = bottomRightView {
                // 원이 움직임을 멈출 때만 사각형을 다시 그립니다.
                repointDrawRectangle(topLeft: topLeftView.center, topRight: topRightView.center, bottomLeft: bottomLeftView.center, bottomRight: bottomRightView.center)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
}

