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
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let barcodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.qr,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.interleaved2of5
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
    
    private func setupVideoPreviewLayer() {
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession!.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
