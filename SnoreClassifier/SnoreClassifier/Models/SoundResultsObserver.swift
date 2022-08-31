//
//  SoundResultsObserver.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation
import SoundAnalysis

class SoundResultsObserver: NSObject, SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        // TODO: classified results 중 가장 정확도 높은 것을 first로 가져옴
        guard let classification = result.classifications.first else { return }
        
        // time of the capture inside the stream
        let timeInSeconds = result.timeRange.start.seconds
        let formattedTime = String(format: "%.2f", timeInSeconds)
        print("Analysis result for audio at time: \(formattedTime)")
        
        // classification confidence
        let confidence = classification.confidence * 100
        let percentString = String(format: "%.2f%%", confidence)
        print("Analysis result confidence: \(percentString)")
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Request failed: \(error.localizedDescription)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Request completed!")
    }
}
