//
//  BarcodeScannerController.swift
//  Playground
//
//  Created by Jack Lai on 19/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import AVFoundation

class BarCodeScannerController: BaseController {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let barcodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    let supportedCodeTypes = [
        AVMetadataObjectTypeQRCode,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeAztecCode,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeITF14Code,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypeDataMatrixCode,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeInterleaved2of5Code
    ]
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupBackButton(color: .white)

        view.addSubview(barcodeFrameView)
        view.addSubview(infoLabel)
        
        infoLabel.snp.makeConstraints({ (make) in
            make.width.bottom.equalTo(view)
        })
        
        setupVideoPreviewLayer()
    }
    
    func setupVideoPreviewLayer() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession!.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
            
            captureSession?.startRunning()
            
            
        } catch {
            fatalError(error as! String)
        }
    }
    
}

extension BarCodeScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            barcodeFrameView.frame = CGRect.zero
            infoLabel.text = "尚未偵測到"
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObject.type) {
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            barcodeFrameView.frame = barcodeObject!.bounds
            if let info = metadataObject.stringValue {
                infoLabel.text = info
            }
        }
    }
    
}
