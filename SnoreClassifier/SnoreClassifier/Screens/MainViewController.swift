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
        label.text = "잘 준비가 되셨나요🤔"
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(24))
        label.textColor = .white
        return label
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
            stopStreamAnalysis()
            changeLabel(from: sleepStatusLabel, to: "잘 준비가 되셨나요🤔")
            changeLabel(from: snoringLabel, to: "")
        } else {
            startStreamAnalysis()
            changeLabel(from: sleepStatusLabel, to: "잘자요😴")
        }
        isObserving.toggle()
    }
    
 
    // MARK: - configures
    private func configureAddSubViews() {
        view.backgroundColor = .systemBackground
        view.addSubViews(sleepStatusLabel,
                         changeStatusButton,
                         snoringLabel)
    }
    
    private func configureConstraints() {
        sleepStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sleepStatusLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor),
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
        let duration = 1.5
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve) {
            label.text = text
        }
    }
    
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
    }
}
