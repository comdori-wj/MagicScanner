//
//  CameraManager.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/2/24.
//

import UIKit
import AVFoundation

final class CameraManager: NSObject {
    var delegate: ViewController?
    private let photoManager = PhotoManager.shared
    private let rectangleDetector = RectangleDetector()
    private lazy var captureImage = UIImage()
    
    private(set) lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        return captureSession
    }()
    
    private var captureImageOutPut = AVCapturePhotoOutput()
    
    private(set) lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resize
        previewLayer.connection?.videoOrientation = .portrait
        
        return previewLayer
    }()
    
    private var videoDataOutput = AVCaptureVideoDataOutput()
    
    func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            print("카메라 권한 인증 전")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { access in
                if access {
                    print("카메라 권한 허용")
                } else {
                    print("카메라 권한 거부")
                    return
                }
            })
        case .restricted:
            print("카메라 권한 불가 상태")
        case .denied:
            print("카메라 권한 거부 상태")
        case .authorized:
            print("카메라 권한 허용 상태")
        @unknown default:
            print("카메라 권한 알수 없는 상태")
        }
    }
    
    func setUpCamera() {
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return print("카메라 불러오기 실패")
        }
        do {
            let deviceInput  = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(deviceInput) && captureSession.canAddOutput(videoDataOutput) {
                if let currentInputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                    for input in currentInputs {
                        captureSession.removeInput(input)
                    }
                }
                videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                captureSession.addInput(deviceInput)
                captureSession.addOutput(videoDataOutput)
            }
        } catch {
            print("카메라 설정 오류: ", error.localizedDescription)
        }
    }
    
    func takePhoto() {
        appendPhoto(image: captureImage)
    }
    
    func appendPhoto(image: UIImage) {
        do {
            try photoManager.setPhoto(image: image)
        } catch {
            print("사진 저장 실패: ", error)
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            lazy var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            lazy var image = UIImage(ciImage: ciImage)
            ciImage = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
            captureImage = image
            
            do {
                let rectangle = try rectangleDetector.detecteRectangle(ciImage: ciImage)
                delegate?.drawRectangle4(forPoints: ciImage,
                                         topLeft: rectangle.topLeft,
                                         topRight: rectangle.topRight,
                                         bottomLeft: rectangle.bottomLeft,
                                         bottomRight: rectangle.bottomRight)
                print("사각형 인식됨")
                
            } catch {
                print(DetectorError.failToDetectRectangle,"\n인식몬함: ", error.localizedDescription)
                delegate?.removeRectangle()
            }
        }
    }
}
