//
//  SoundResultsObserver.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation
import SoundAnalysis

protocol IsRecordedObserverDelegate: AnyObject {
    func showYouSnoredLabel()
}

class SoundResultsObserver: NSObject, SNResultsObserving {
    
    weak var delegate: IsRecordedObserverDelegate?
    
    var snoreRecorder = SnoreRecorder.snoreRecorder
    var audioSession: AVAudioSession?
    var isRecordingInitial: Bool = true
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        // TODO: classified results 중 가장 정확도 높은 것을 first로 가져옴
        guard let snoringClassification = result.classification(forIdentifier: "1") else { return }
        
        // classification confidence
        let snoringConfidence = snoringClassification.confidence * 100
        if snoringConfidence >= 90 {
            // time of the capture inside the stream
            // let snoredTimeInSeconds = result.timeRange.start.seconds
            // let formattedTime = String(format: "%.2f", snoredTimeInSeconds)
            // print("Analysis result for audio at time: \(formattedTime)")
            if isRecordingInitial {
                recordWhenSnore()
                isRecordingInitial = false
            }
            delegate?.showYouSnoredLabel()
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
    }
    
    func playRecordedSnore() {
        snoreRecorder.startPlaying()
    }
    
    func pauseRecordedSnore() {
        snoreRecorder.pausePlaying()
    }
}
