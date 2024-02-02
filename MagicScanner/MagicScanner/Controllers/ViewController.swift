//
//  ViewController.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/2/24.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    private let cameraManager = CameraManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        cameraManager.previewLayer.frame = cameraView.bounds
        
        DispatchQueue.main.async {
            self.cameraManager.captureSession.startRunning()
        }
    }


}

