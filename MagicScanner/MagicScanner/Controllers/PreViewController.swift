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
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImageView(image: photoManager.onePhoto())
    }
    
    func updateImageView(image: UIImage) {
        imageView?.image = image
        let count = photoManager.originalPhotos.count
        print("프리뷰 사진 갯수 확인: ", count)
    }
    
}
