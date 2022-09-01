//
//  SnoreRecorder.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/31.
//

import Foundation
import AVFoundation

class SnoreRecorder: NSObject, AVAudioPlayerDelegate {
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var savedPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static var snoreRecorder = SnoreRecorder()
    lazy var fileURL: URL = savedPath.appendingPathComponent(fileName)
    var fileName: String = "\(Date.now.toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a"
    
    // MARK: - initialize
    override init() {
        super.init()
    }
    
    
    // MARK: - before recording
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the recording")
            fatalError()
        }
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            print("recording started")
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.stopRecording()
            }
        } catch {
            print("failed to setup the recording")
            fatalError()
        }
    }
    
    
    // MARK: - after recording
    func stopRecording() {
        audioRecorder.stop()
        print("recording stopped")
        do {
            try print(Data(contentsOf: fileURL).description)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startPlaying() {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("Playing failed in device")
            print(error.localizedDescription)
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("start playing")
        } catch {
            print("Playing failed: \(error.localizedDescription)")
        }
    }
    
    func pausePlaying() {
        audioPlayer.pause()
    }
    
    func deleteRecording() {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("recording: \(fileName) deleted")
        } catch {
            print("Recording cannot be deleted")
        }
    }
}
