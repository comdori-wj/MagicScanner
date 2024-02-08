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
    let rectangleDetector = RectangleDetector()
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
            // 기존의 input을 제거합니다.
            if let currentInputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in currentInputs {
                    captureSession.removeInput(input)
                }
            }
            
            // 기존의 output을 제거합니다.
            if let currentOutputs = captureSession.outputs as? [AVCaptureOutput] {
                for output in currentOutputs {
                    captureSession.removeOutput(output)
                }
            }
            
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            captureSession.addInput(deviceInput)
            captureSession.addOutput(videoDataOutput)

        } catch {
            print("카메라 설정 오류: ", error.localizedDescription)
        }
    }
    
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            lazy var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            ciImage = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
            
            //            let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            do {
                
                
                let rectangle = try rectangleDetector.detecteRectangle(ciImage: ciImage)
                //                ectangleDetector.detecteRectangle(ciImage: ciImage)
                
                // MARK: - convertCIImageToUIImage 방식으로 사각형 인식
                //                guard let rectangleImage = delegate?.drawHighlightOverlay(forPoints: ciImage,
                //                                                                          topLeft: rectangle.topLeft,
                //                                                                          topRight: rectangle.topRight,
                //                                                                          bottomLeft: rectangle.bottomLeft,
                //                                                                          bottomRight: rectangle.bottomRight) else { return print("sdsds")}
                //
                //                if let highlightedUIImage = delegate?.convertCIImageToUIImage(ciImage: rectangleImage) {
                //                    DispatchQueue.main.async {
                //                        self.delegate?.drawRectangle2(image: highlightedUIImage)
                //                    }
                //                }
                
                
                
                // MARK: - UIBezierPath를 이용하여 사각형 인식
                
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