//
//  ImageRecognitionController.swift
//  Playground
//
//  Created by Jack Lai on 01/10/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import CoreML
import Vision

@available(iOS 11.0, *)
class ImageRecognitionController: BaseController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let model = Inceptionv3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Image Recognition"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "讀取", style: .plain, target: self, action: #selector(loadImage))
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(view.snp.width)
            make.top.equalTo(view).offset(64)
            make.bottom.equalTo(label.snp.top)
        }
        
        label.snp.makeConstraints { (make) in
            make.width.bottom.equalTo(view)
            make.height.equalTo(100)
        }
    }
    
    @objc private func loadImage() {
        let controller = UIAlertController(title: "選取照片", message: "請選擇以下方式", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (action) in
            self.openCamera()
        }
        let albumAction = UIAlertAction(title: "相簿", style: .default) { (action) in
            self.openAlbum()
        }
        controller.addAction(cameraAction)
        controller.addAction(albumAction)
        present(controller, animated: true, completion: nil)
    }
    
    private func openCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: "目前裝置無法開啟相機功能", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        present(cameraPicker, animated: true, completion: nil)
    }
    
    private func openAlbum() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func detectFaces(image: UIImage) {
        imageView.subviews.forEach { $0.removeFromSuperview() }
        imageView.image = image
        
        let imageScaledHeight = view.frame.width / image.size.width * image.size.height
        let offsetY = (imageView.frame.height - imageScaledHeight) / 2
        
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            if let error = error {
                print("Failed to detect faces:", error)
            }
            
            request.results?.forEach({ (result) in
                guard let faceObservation = result as? VNFaceObservation else { return }
                
                let boundingBox = faceObservation.boundingBox
                let width = self.view.frame.width * boundingBox.width
                let height = imageScaledHeight * boundingBox.height
                let x = self.view.frame.width * boundingBox.origin.x
                let y = imageScaledHeight * (1 - boundingBox.origin.y) - height + offsetY
                
                let faceView = UIView()
                faceView.layer.borderColor = UIColor.red.cgColor
                faceView.layer.borderWidth = 2
                faceView.frame = CGRect(x: x, y: y, width: width, height: height)
                self.imageView.addSubview(faceView)
            })
        }
        
        guard let cgImage = image.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch let requestError {
            print("Failed to perform request:", requestError)
        }
    }
    
    private func recognizeImage(image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        guard let prediction = try? model.prediction(image: pixelBuffer!) else { return }
        
        label.text = prediction.classLabel
    }
    
}

@available(iOS 11.0, *)
extension ImageRecognitionController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        label.text = "分析中..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
        detectFaces(image: image)
        recognizeImage(image: image)
    }
    
}
