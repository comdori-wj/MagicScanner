//
//  ViewController.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/2/24.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    @IBOutlet weak  var cameraView: UIView!

    private let cameraManager = CameraManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraManager.checkCameraPermission()
        setUpCameraView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.captureSession.stopRunning()
    }
    
    func setUpCameraView() {
        cameraManager.setUpCamera()
        
        cameraView.layer.addSublayer(cameraManager.previewLayer)
        cameraManager.previewLayer.frame = cameraView.frame
        
        DispatchQueue.global().async {
            self.cameraManager.captureSession.startRunning()
        }
    }
}

extension ViewController {
    @IBAction func cancelButtonTapped(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("앱을 종료합니다")
            exit(0)
        }
    }
}

extension ViewController {
    func drawRectangle2(image: UIImage) {
        DispatchQueue.main.async {
            // 기존에 추가된 모든 이미지 뷰를 제거합니다.
            for subview in self.cameraView.subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
            }
            let imageView = UIImageView(frame: self.cameraView.bounds)
            imageView.image = image
            
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor.red.cgColor
            self.cameraView.addSubview(imageView)
        }
    }
    
    
    //    func drawRectangle2(image: UIImage) {
    //        DispatchQueue.main.async {
    //            // 기존에 추가된 모든 이미지 뷰를 제거합니다.
    //            for subview in self.cameraView.subviews {
    //                if subview is UIImageView || subview is RectangleView {
    //                    subview.removeFromSuperview()
    //                }
    //            }
    //
    //            let imageView = UIImageView(frame: self.cameraView.bounds)
    //            imageView.image = image
    //            self.cameraView.addSubview(imageView)
    //
    //            // 사각형의 좌표를 결정합니다.
    //            let topLeft = CGPoint(x: 0, y: 0)
    //            let topRight = CGPoint(x: imageView.bounds.width, y: 0)
    //            let bottomRight = CGPoint(x: imageView.bounds.width, y: imageView.bounds.height)
    //            let bottomLeft = CGPoint(x: 0, y: imageView.bounds.height)
    //
    //            // RectangleView를 생성하고 imageView 위에 추가합니다.
    //            let rectangleView = RectangleView(frame: imageView.bounds, rectangle: [topLeft, topRight, bottomRight, bottomLeft])
    //            imageView.addSubview(rectangleView)
    //        }
    //    }
    
    
    
    
    
    //    func drawRectangle3(rectFeature: Rectangle, imageSize: CGSize) {
    //        let shapeLayer = CAShapeLayer()
    //        let path = UIBezierPath()
    //
    //        // 사각형의 좌표를 카메라 뷰의 좌표계로 변환합니다.
    //        let scale = cameraView.frame.size.width / imageSize.width
    //        let transform = CGAffineTransform(scaleX: scale, y: scale)
    //
    //        let topLeft = rectFeature.topLeft.applying(transform)
    //        let topRight = rectFeature.topRight.applying(transform)
    //        let bottomRight = rectFeature.bottomRight.applying(transform)
    //        let bottomLeft = rectFeature.bottomLeft.applying(transform)
    //
    //        path.move(to: topLeft)
    //        path.addLine(to: topRight)
    //        path.addLine(to: bottomRight)
    //        path.addLine(to: bottomLeft)
    //        path.close()
    //
    //        shapeLayer.path = path.cgPath
    //        shapeLayer.fillColor = (UIColor(red: 0.26, green: 0.67, blue: 0.88, alpha: 1.00).cgColor).copy(alpha: 0.5)
    //        shapeLayer.strokeColor = UIColor(red: 0.31, green: 0.33, blue: 0.49, alpha: 1.00).cgColor
    //        shapeLayer.lineWidth = 2
    //
    //        cameraView.layer.addSublayer(shapeLayer)
    //        self.shapeLayer = shapeLayer
    //    }
    
    //    func drawHighlightOverlay(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
    //        var overlay = CIImage(color: CIColor(red: CGFloat(0.26), green: CGFloat(0.67), blue: CGFloat(1), alpha: CGFloat(0.5)))
    //        overlay = overlay.cropped(to: image.extent)
    //        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
    //                                         parameters: [
    //                                            "inputExtent": CIVector(cgRect: image.extent),
    //                                            "inputTopLeft": CIVector(cgPoint: topLeft),
    //                                            "inputTopRight": CIVector(cgPoint:topRight),
    //                                            "inputBottomLeft": CIVector(cgPoint:bottomLeft),
    //                                            "inputBottomRight": CIVector(cgPoint:bottomRight)
    //                                         ])
    //        return overlay.composited(over: image)
    //    }
    
    func drawHighlightOverlay(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: CGFloat(0.26), green: CGFloat(0.67), blue: CGFloat(1), alpha: CGFloat(0.5)))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         parameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint:topRight),
                                            "inputBottomLeft": CIVector(cgPoint:bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint:bottomRight)
                                         ])
        return overlay.composited(over: image)
    }
    
    func removeRectangle() {
        DispatchQueue.main.async {
            self.cameraView.layer.sublayers?
                .filter { $0 is CAShapeLayer }
                .forEach { $0.removeFromSuperlayer() }
            print("사각형 지워")
        }
    }
    
    func drawRectangle4(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        
        // 이전에 그려진 테두리를 제거합니다.
        removeRectangle()
        
        DispatchQueue.main.async {
            // 이미지와 화면 사이의 비율을 계산합니다.
            let imageRect = AVMakeRect(aspectRatio: image.extent.size, insideRect: self.cameraView.bounds)
            
            let imageView = UIImageView(frame: imageRect)
            imageView.image = UIImage(ciImage: image)
            
            let transform = self.transformForImageView(imageView: imageView)
            
            
            let transformedTopLeft = topLeft.applying(transform)
            let transformedTopRight = topRight.applying(transform)
            let transformedBottomLeft = bottomLeft.applying(transform)
            let transformedBottomRight = bottomRight.applying(transform)
            
            // 변환된 좌표를 사용하여 사각형을 그립니다.
            let path = UIBezierPath()
            path.move(to: transformedTopLeft)
            path.addLine(to: transformedTopRight)
            path.addLine(to: transformedBottomRight)
            path.addLine(to: transformedBottomLeft)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor(red: 66/255, green: 171/255, blue: 225/255, alpha: 0.5).cgColor
            shapeLayer.strokeColor = UIColor(red: 79/255, green: 84/255, blue: 125/255, alpha: 1.0).cgColor
            shapeLayer.lineWidth = 2
            
            self.cameraView.layer.addSublayer(shapeLayer)
        }
    }
    
    func transformForImageView(imageView: UIImageView) -> CGAffineTransform {
        
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
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) / 0.5
        transform = CGAffineTransformTranslate(transform, tx, ty)
        
        // Scale to match UIImageView scaling.
        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)
        
        return transform
    }
    
    
    
    
    
    //    func drawHighlightOverlay4(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
    //        DispatchQueue.main.async {
    //            // 이전에 그려진 테두리를 제거합니다.
    //            self.cameraView.layer.sublayers?
    //                .filter { $0 is CALayer }
    //                .forEach { $0.removeFromSuperlayer() }
    //
    //            // 이미지와 화면 사이의 비율을 계산합니다.
    //            let imageRect = AVMakeRect(aspectRatio: image.extent.size, insideRect: self.cameraView.bounds)
    //
    //            // 비율에 따라 좌표를 변환합니다.
    //            let transform = CGAffineTransform(translationX: imageRect.origin.x, y: imageRect.origin.y)
    //                .scaledBy(x: imageRect.width / image.extent.width, y: imageRect.height / image.extent.height)
    //
    //            let transformedTopLeft = topLeft.applying(transform)
    //            let transformedTopRight = topRight.applying(transform)
    //            let transformedBottomLeft = bottomLeft.applying(transform)
    //            let transformedBottomRight = bottomRight.applying(transform)
    //
    //            // 변환된 좌표를 사용하여 사각형을 그립니다.
    //            let path = UIBezierPath()
    //            path.move(to: transformedTopLeft)
    //            path.addLine(to: transformedTopRight)
    //            path.addLine(to: transformedBottomRight)
    //            path.addLine(to: transformedBottomLeft)
    //            path.close()
    //
    //            // CIImage를 CGImage로 변환합니다.
    //            let context = CIContext()
    //            if let cgImage = context.createCGImage(image, from: image.extent) {
    //                // CGImage를 contents로 가지는 CALayer를 생성합니다.
    //                let imageLayer = CALayer()
    //                imageLayer.frame = self.cameraView.bounds
    //                imageLayer.contents = cgImage
    //                imageLayer.contentsGravity = .resizeAspectFill
    //
    //                self.cameraView.layer.addSublayer(imageLayer)
    //            }
    //        }
    //    }
    
    
    func convertCIImageToUIImage(ciImage: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
