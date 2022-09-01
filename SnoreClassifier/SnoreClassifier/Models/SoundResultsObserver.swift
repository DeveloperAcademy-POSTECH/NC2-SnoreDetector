//
//  SoundResultsObserver.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation
import SoundAnalysis

class SoundResultsObserver: NSObject, SNResultsObserving {
    
    var snoreRecorder = SnoreRecorder.snoreRecorder
    var audioSession: AVAudioSession?
    var isRecordingInitial: Bool = true
    var confidence: String = ""
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        // TODO: classified results 중 가장 정확도 높은 것을 first로 가져옴
        guard let snoringClassification = result.classification(forIdentifier: "1") else { return }
        
        // classification confidence
        let snoringConfidence = snoringClassification.confidence * 100
        if snoringConfidence >= 80 {
            let snoringPercentString = String(format: "%.2f%%", snoringConfidence)
            confidence = snoringPercentString
            print("Snoring analysis result confidence: \(confidence)")
            
            // time of the capture inside the stream
            let snoredTimeInSeconds = result.timeRange.start.seconds
            let formattedTime = String(format: "%.2f", snoredTimeInSeconds)
            print("Analysis result for audio at time: \(formattedTime)")
            
            if isRecordingInitial {
                recordWhenSnore()
                isRecordingInitial = false
                print("after recording: \(SnoreRecorder.snoreRecorder.fileURL)")
            }
            print(isRecordingInitial)
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Request failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Request completed!")
    }
    
}

// MARK: - recording and playing
extension SoundResultsObserver {
    func recordWhenSnore() {
        snoreRecorder.startRecording()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.snoreRecorder.stopRecording()
//        }
    }
    
    func playRecordedSnore() {
        print("before playing: \(SnoreRecorder.snoreRecorder.fileURL)")
//        snoreRecorder.fileURL != URL(string: "")! {
//            snoreRecorder.startPlaying()
//        }
        snoreRecorder.startPlaying()
    }
}
