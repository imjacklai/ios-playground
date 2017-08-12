//
//  SpeechController.swift
//  Playground
//
//  Created by Jack Lai on 16/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Speech

class SpeechController: BaseController {
    
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_Hant"))
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    fileprivate let outputLabel = UILabel()
    fileprivate let microphoneButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupBackButton(color: .black)
        
        let label = UILabel()
        label.text = "按下錄音按鈕並開始說話"
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        outputLabel.font = UIFont.systemFont(ofSize: 20)
        outputLabel.numberOfLines = 0
        
        microphoneButton.isEnabled = false
        microphoneButton.setTitle("開始錄音", for: .normal)
        microphoneButton.addTarget(self, action: #selector(microphoneButtonTapped), for: .touchUpInside)
        
        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(outputLabel)
        view.addSubview(microphoneButton)
        
        label.snp.makeConstraints { (make) in
            make.width.equalTo(view).offset(-80)
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view)
        }
        
        outputLabel.snp.makeConstraints { (make) in
            make.width.equalTo(view).offset(-80)
            make.center.equalTo(view)
        }
        
        microphoneButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-40)
            make.centerX.equalTo(view)
        }
        
        requestSpeechAuthorization()
    }
    
    @objc fileprivate func microphoneButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.setTitle("開始錄音", for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("停止錄音", for: .normal)
        }
    }
    
    fileprivate func requestSpeechAuthorization() {
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            var isButtonEnabled = false
            
            switch status {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
            case .restricted:
                isButtonEnabled = false
            case .notDetermined:
                isButtonEnabled = false
            }
            
            OperationQueue.main.addOperation {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    fileprivate func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("AudioSession properties weren't set because of an error")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            
            if result != nil {
                self.outputLabel.text = result?.bestTranscription.formattedString
                isFinal = result!.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine couldn't start because of an error")
        }
        
        outputLabel.text = "請說話，正在錄音中..."
    }
    
}

extension SpeechController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        microphoneButton.isEnabled = available
    }
    
}
