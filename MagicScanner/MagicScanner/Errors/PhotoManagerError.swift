//
//  PhotoManagerError.swift
//  MagicScanner
//
//  Created by Wonji Ha on 2024/02/11.
//

import Foundation

enum PhotoManagerError: Error, CustomStringConvertible {
    case convertToCIImageError
    case failToOutputRectangleImage
    case failToCreateCGImage
    
    var description: String {
        switch self {
        case .convertToCIImageError:
            return "CIImage 변환을 실패하였습니다."
        case .failToOutputRectangleImage:
            return "사각형 이미지를 출력하지 못하였습니다"
        case .failToCreateCGImage:
            return "CGImage 생성을 실패하였습니다."
        }
    }
}
