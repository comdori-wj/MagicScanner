//
//  MainViewController.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/2/24.
//

import UIKit
import AVFoundation

final class MainViewController: UIViewController {
    @IBOutlet weak private var cameraView: UIView!
    private let cameraManager = CameraManager()
    private let photoManager = PhotoManager.shared
    @IBOutlet weak var previewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraManager.checkCameraPermission()
        setUpCameraView()
        previewButtonImageChange()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.captureSession.stopRunning()
        
    }
    
    private func previewButtonImageChange() {
        if photoManager.perspectivePhotos.isEmpty {
            previewButton.setImage(UIImage(systemName: "photo"), for: .normal)
            previewButton.layer.borderWidth = 2
            previewButton.layer.borderColor = UIColor.systemBrown.cgColor
        } else {
            previewButton.setImage(photoManager.perspectivePhotos.last, for: .normal)
        }
    }
    
    func setUpCameraView() {
        cameraManager.setUpCamera()
        
        cameraView.layer.addSublayer(cameraManager.previewLayer)
        cameraManager.previewLayer.frame = cameraView.bounds
        
        DispatchQueue.global().async {
            self.cameraManager.captureSession.startRunning()
        }
    }
}

extension MainViewController {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("앱을 종료합니다")
            exit(0)
        }
    }
    
    @IBAction private func preViewButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let preViewController = storyboard.instantiateViewController(withIdentifier: "PreViewController") as? PreViewController else { return }
        
        navigationController?.pushViewController(preViewController, animated: true)
    }
    
    @IBAction private func shutterButtonTapped(_ sender: Any) {
        print("촬영 버튼 누름")
        cameraManager.takePhoto()
        previewButtonImageChange()
    }
    
}

extension MainViewController {
    func removeRectangle() {
        DispatchQueue.main.async {
            self.cameraView.layer.sublayers?
                .filter { $0 is CAShapeLayer }
                .forEach { $0.removeFromSuperlayer() }
            print("사각형 지워")
        }
    }
    
    func drawRectangle(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        
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
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) / 0.2 - 30
        transform = CGAffineTransformTranslate(transform, tx, ty)
        
        // Scale to match UIImageView scaling.
        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)
        
        return transform
    }
}
