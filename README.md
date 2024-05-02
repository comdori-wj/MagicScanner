# 🔲 MagicScanner
> 카메라와 CoreImage 프레임워크를 이용하여 사각형을 인식하는 앱

<br/>

## 🌲 목차
- 프로젝트 참여자 
- 프로젝트 기간
- 구현 화면
- 디렉토리 구조
- 핵심 구현사항
- 트러블 슈팅
<br/>

## 👨🏻‍💻 프로젝트 참여자

| <a href="https://github.com/comdori-wj"> <img src="https://avatars.githubusercontent.com/u/22284092?v=4" width="200" height="200"></a> |
| --------- |
|[@Comdori](https://github.com/comdori-wj)|


<br/>

## 📆 프로젝트 기간
> 2024.01.30 ~ 2024.02.13

<br/>

## 📸 구현 화면


|사물 사각형 인식|미리보기화면|Repoint|
|:---:|:---:|:---:|
<img width="488" alt="사각형인식" src="https://github.com/comdori-wj/MagicScanner/assets/22284092/bd90adb0-c50b-4ce8-86d3-ab8f290b2632">|<img width="488" alt="미리보기화면(사물 prepective)" src="https://github.com/comdori-wj/MagicScanner/assets/22284092/2d30a3b3-41ae-4689-bd03-0e644de54361">|<img width="488" alt="repoint" src="https://github.com/comdori-wj/MagicScanner/assets/22284092/a1dafa13-3a4f-4c04-b064-52f315ca5bf0">|

https://github.com/comdori-wj/MagicScanner/assets/22284092/84c35921-a18e-4a02-8792-4dbf7c32da8b

<br/> 


## 📁 디렉토리 구조 

```
.
├── MagicScanner
│   ├── AppDelegate
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   ├── Contents.json
│   │   └── Image.imageset
│   │       └── Contents.json
│   ├── Controllers
│   │   ├── MainViewController.swift
│   │   ├── PreViewController.swift
│   │   └── RepointViewController.swift
│   ├── Errors
│   │   ├── DetectorError.swift
│   │   └── PhotoManagerError.swift
│   ├── Extensions
│   │   └── UIImageView+Extension.swift
│   ├── Info.plist
│   ├── Services
│   │   ├── CameraManager.swift
│   │   ├── PhotoManager.swift
│   │   ├── Rectangle.swift
│   │   └── RectangleDetector.swift
│   └── Views
│       └── Base.lproj
│           ├── LaunchScreen.storyboard
│           └── Main.storyboard
├── MagicScanner.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   └── swiftpm
│   │   │       └── configuration
│   │   └── xcuserdata
│   │       └── wj.xcuserdatad
│   │           └── UserInterfaceState.xcuserstate
│   ├── xcshareddata
│   │   └── xcschemes
│   │       └── MagicScanner.xcscheme
│   └── xcuserdata
│       └── wj.xcuserdatad
│           └── xcdebugger
│               └── Breakpoints_v2.xcbkptlist
├── MagicScannerTests
│   └── MagicScannerTests.swift
└── MagicScannerUITests
    ├── MagicScannerUITests.swift
    └── MagicScannerUITestsLaunchTests.swift
```

<br/>

## 🌟 핵심 구현사항

### 촬영화면
- AVFoundation 프레임워크를 이용하여 카메라뷰(AVCaptureVideoPreviewLayer)구현
- 셔터를 눌렀을때 사진을 저장하기 위해 `CMSampleBufferGetImageBuffer`의 `CIImage`를 저장하여 촬영 버튼을 구현

### 물체인식
- CoreImage 프레임워크를 사용하여 CIRectangleFeature를 이용하여 사각형을 감지
- 사각형의 4각의 포인트를 지정하여 구현
- 사각형은 Core Graphics 프레임워크의 UIBezierPath를 이용하여 사각형을 실시간으로 그림


### 촬영된 이미지 미리보기
- 인식된 이미지는 싱글톤으로 구현된 배열에 저장하여 어느 뷰에서든 호출하여 사용 가능.
- 사각형의 4포인트에 맞게 사진을 자름(Prepective)
- 반시계 회전시 이미지의 크기가 줄어들지 않게 우너래의 크기를 가져온후 계산후 회전된 이미질르 보이게 구현
- 이미지 삭제는 현재 보이는 index 번호를 가져온후 해당하는 이미지를 삭제, 모두 삭제시 예외사항 적용하여 앱이 크래쉬 되지 않음.

### Repoint
- 편집되지 않은 원본 이미지를 불러온뒤 사물의 사각형을 인식후 사각형을 표시
- 각 포인트(원)은 UIPanGestureRecognizer를 이용하여 포인트를 움직여서 사각형을 만듬.
- 사각형을 인식하지 못한 경우 원본 이미지의 가운데에 임의 사각형을 표시


<br/>

## 🚀 트러블 슈팅

#### 1. 실시간 사각형 인식 화면(메인 카메라) 버벅대는 문제
- **사유**
사물을 인식 후 사각형을 Image로 카메라뷰에 붙여 넣는 방식을 사용하여 카메라 방향이 달라지거나 새로운 물체를 인식할 때마다 지웠다가 붙여 넣는 작업을 반복함으로써 많은 메모리 사용하여 버벅대는 문제가 발생


https://github.com/comdori-wj/MagicScanner/assets/22284092/4bbf5372-dae1-49b2-a8ab-d605d4234967






- **문제 해결**
UIBezierPath를 통해 사각형을 그림으로써 카메라 방향이 달라지거나 새로운 물체를 인식할 때 버벅대는 현상을 해결



https://github.com/comdori-wj/MagicScanner/assets/22284092/04822fd1-3321-4491-9183-b335f4c36f2f






<br>

#### 2. 사각형이 잘못그려지는 문제

- **사유**
Core Image의 좌표와 UIkit의 좌표 시스템이 달라서 카메라뷰에 사각형이 다르게 표시되는 문제가 발생
<img src="https://github.com/comdori-wj/MagicScanner/assets/22284092/d00cf472-0992-4b20-ac0e-6c8e6b5d6b4e" width="350" height="800">



- **문제 해결**
Core Image로 받아온 좌표를 UIkit에 맞추어 변환을 하여 그나마 사각형이 물체에 맞게 표시됨
<img src="https://github.com/comdori-wj/MagicScanner/assets/22284092/3279016f-6aa8-4bfa-8947-63dc6385cfad" width="350" height="800">



