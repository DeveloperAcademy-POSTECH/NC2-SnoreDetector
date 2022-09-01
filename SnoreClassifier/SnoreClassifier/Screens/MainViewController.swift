//
//  MainViewController.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import UIKit
import SwiftUI
import AVKit
import SoundAnalysis

final class MainViewController: UIViewController {
    
    // MARK: - sound classification initializations
    private let audioEngine = AVAudioEngine()
    private let inputBus: AVAudioNodeBus = AVAudioNodeBus(0)
    private let analysisQueue = DispatchQueue(label: "com.AnalysisQueue")
    private var snoringClassifier: SnoreClassification?
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private var resultsObserver = SoundResultsObserver()
    private var isObserving: Bool = false
    
    
    // MARK: - size
    private enum Size {
        static let padding: CGFloat = 15.0
        static let width: CGFloat = UIScreen.main.bounds.width * 0.8
        static let height: CGFloat = 55.0
        static let cornerRadius: CGFloat = 15.0
    }
    

    // MARK: - properties
    private let sleepStatusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "잘 준비가 되셨나요🤔\n핸드폰을 꺼두셔도 됩니다😌"
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(24))
        label.textColor = .white
        return label
    }()
    private let youSnoredLabel: UILabel = {
        let label = UILabel()
        label.text = "dsf"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    private let feedbackView: FeedbackPopUpView = {
        let view = FeedbackPopUpView()
        return view
    }()
    private lazy var snoringLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: CGFloat(20))
        label.textColor = .white
        return label
    }()
    private lazy var changeStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("나..코고나😬", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(20))
        button.backgroundColor = UIColor(Color.buttonColor)
        button.layer.cornerRadius = Size.cornerRadius
        button.addTarget(self, action: #selector(startObserving), for: .touchUpInside)
        return button
    }()
    private lazy var playSnoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 코골이 들어보기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        button.backgroundColor = UIColor(Color.buttonColor)
        button.layer.cornerRadius = Size.cornerRadius
        button.addTarget(self, action: #selector(playRecordedSnore), for: .touchUpInside)
        return button
    }()
    private lazy var pauseSnoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 코골이 일시정지", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
        button.backgroundColor = UIColor(Color.buttonColor)
        button.layer.cornerRadius = Size.cornerRadius
        button.addTarget(self, action: #selector(pauseRecordedSnore), for: .touchUpInside)
        return button
    }()
    
//    private lazy var stopRecordingButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("녹음 그만", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
//        button.backgroundColor = UIColor(Color.buttonColor)
//        button.layer.cornerRadius = Size.cornerRadius
//        button.addTarget(self, action: #selector(stopRecordingSnore), for: .touchUpInside)
//        return button
//    }()
//    private lazy var deleteRecordingButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("녹음 삭제", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: CGFloat(16))
//        button.backgroundColor = UIColor(Color.buttonColor)
//        button.layer.cornerRadius = Size.cornerRadius
//        button.addTarget(self, action: #selector(deleteRecordedSnore), for: .touchUpInside)
//        return button
//    }()
    
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAddSubViews()
        configureConstraints()
        configureUI()
        configureMLModel()
    }
    
    
    // MARK: - selector
    @objc func startObserving() {
        if isObserving {
            resultsObserver.isRecordingInitial = true
            stopStreamAnalysis()
            print("stop observing")
            changeLabel(from: youSnoredLabel, to: "")
            changeLabel(from: sleepStatusLabel, to: "잘 준비가 되셨나요🤔\n핸드폰을 꺼두셔도 됩니다😌")
            changeButtonLabel(from: changeStatusButton, to: "나..코고나😬")
        } else {
            startStreamAnalysis()
            print("start observing")
            changeLabel(from: sleepStatusLabel, to: "잘자요😴")
            changeButtonLabel(from: changeStatusButton, to: "하암..잘잤다🥱")
            resultsObserver.snoreRecorder.deleteRecording()
        }
        isObserving.toggle()
    }
    
    @objc func playRecordedSnore() {
        resultsObserver.playRecordedSnore()
    }
    
    @objc func pauseRecordedSnore() {
        resultsObserver.pauseRecordedSnore()
    }
    
//    @objc func stopRecordingSnore() {
//        resultsObserver.snoreRecorder.stopRecording()
//        print("recording stopped")
//    }
    
//    @objc func deleteRecordedSnore() {
//        resultsObserver.snoreRecorder.deleteRecording()
//        resultsObserver.isRecordingInitial = false
//    }
 
    // MARK: - configures
    private func configureAddSubViews() {
        view.backgroundColor = .systemBackground
        view.addSubViews(sleepStatusLabel,
                         youSnoredLabel,
                         changeStatusButton,
                         snoringLabel,
                         playSnoreButton,
                         pauseSnoreButton)
    }
    
    private func configureConstraints() {
        sleepStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sleepStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        youSnoredLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            youSnoredLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            youSnoredLabel.topAnchor.constraint(equalTo: sleepStatusLabel.bottomAnchor, constant: Size.padding)
        ])
        
        changeStatusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeStatusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeStatusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            changeStatusButton.widthAnchor.constraint(equalToConstant: Size.width),
            changeStatusButton.heightAnchor.constraint(equalToConstant: Size.height),
        ])
        
        snoringLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            snoringLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snoringLabel.topAnchor.constraint(equalTo: sleepStatusLabel.bottomAnchor, constant: Size.padding),
        ])
        
        playSnoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playSnoreButton.bottomAnchor.constraint(equalTo: changeStatusButton.topAnchor, constant: -Size.padding),
            playSnoreButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -Size.padding/2),
            playSnoreButton.leftAnchor.constraint(equalTo: changeStatusButton.leftAnchor),
            playSnoreButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        pauseSnoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pauseSnoreButton.bottomAnchor.constraint(equalTo: changeStatusButton.topAnchor, constant: -Size.padding),
            pauseSnoreButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: Size.padding/2),
            pauseSnoreButton.rightAnchor.constraint(equalTo: changeStatusButton.rightAnchor),
            pauseSnoreButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
//        deleteRecordingButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            deleteRecordingButton.bottomAnchor.constraint(equalTo: changeStatusButton.topAnchor, constant: -Size.padding),
//            deleteRecordingButton.rightAnchor.constraint(equalTo: playSnoreButton.leftAnchor, constant: -Size.padding/2),
//            deleteRecordingButton.leftAnchor.constraint(equalTo: changeStatusButton.leftAnchor),
//        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .black
    }
    
    private func configureMLModel() {
        snoringClassifier = try? SnoreClassification()
    }
}


// MARK: - other functions
extension MainViewController {
    
    // UI functions
    func changeLabel(from label: UILabel, to text: String) {
        let duration = 0.7
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve) {
            label.text = text
        }
    }
    
    func changeButtonLabel(from button: UIButton, to text: String) {
        let duration = 0.7
        UIView.transition(with: button, duration: duration, options: .transitionCrossDissolve) {
            button.setTitle(text, for: .normal)
        }
    }
    
//    func changeYouSnoredLabel() {
//        if resultsObserver.isRecorded {
//            changeLabel(from: youSnoredLabel, to: "당신은 코를 골았습니다..👃")
//        } else {
//            changeLabel(from: youSnoredLabel, to: "")
//        }
//    }
    
    // Analysis functions
    func startStreamAnalysis() {
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        
        do {
            try audioEngine.start()
            audioEngine.inputNode.installTap(onBus: inputBus, bufferSize: 8192, format: inputFormat, block: analyzeAudio(buffer:at:))
            streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
            guard let snoringClassifierModel = snoringClassifier?.model else {
                print("--- Model not available ---")
                fatalError()
            }
            let request = try SNClassifySoundRequest(mlModel: snoringClassifierModel)
            try streamAnalyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }
    
    func stopStreamAnalysis() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}


// MARK: - IsRecordedObserverDelegate
extension MainViewController: IsRecordedObserverDelegate {
    func showYouSnoredLabel() {
        print("function activated")
        UIView.transition(with: youSnoredLabel, duration: 0.7) {
            self.youSnoredLabel.text = "당신은 코를 골았습니다..👃"
        }
    }
}
