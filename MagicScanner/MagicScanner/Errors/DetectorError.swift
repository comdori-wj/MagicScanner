//
//  DetectorError.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2/5/24.
//

import Foundation

enum DetectorError: Error, CustomStringConvertible {
    case failToDetectRectangle
    case failToGetPerspectiveCorrectionImage
    
    var description: String {
        switch self {
        case .failToDetectRectangle:
            return "cantFindRectangle: 사각형을 찾지 못했습니다."
        case .failToGetPerspectiveCorrectionImage:
            return "failToGetPerspectiveCorrectionImage: 스캔된 이미지를 가지고 오는데 실패했습니다."
        }
    }
}
