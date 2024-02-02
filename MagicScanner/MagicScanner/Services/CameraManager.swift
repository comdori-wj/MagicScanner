//
//  CameraManager.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/2/24.
//

import UIKit
import AVFoundation

final class CameraManager {
    private(set) lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1920x1080
        return captureSession
    }()
    
    private var captureImageOutPut: AVCapturePhotoOutput!
    
    private(set) lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        
        return previewLayer
    }()
    
    private var videoDataOutput: AVCaptureVideoDataOutput!
    
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
            captureImageOutPut = AVCapturePhotoOutput()
            if captureSession.canAddInput(deviceInput) && captureSession.canAddOutput(captureImageOutPut) {
                captureSession.addInput(deviceInput)
                captureSession.addOutput(captureImageOutPut)
            }
        } catch {
            print("카메라 설정 오류: ", error.localizedDescription)
        }
    }
}
