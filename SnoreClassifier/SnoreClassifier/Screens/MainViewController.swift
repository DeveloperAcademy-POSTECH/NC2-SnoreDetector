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
    
    
    // MARK: - size
    private enum Size {
        static let padding: CGFloat = 15.0
        static let width: CGFloat = UIScreen.main.bounds.width * 0.8
        static let height: CGFloat = 55.0
        static let cornerRadius: CGFloat = 15.0
    }
    
    
    // MARK: - properties
    private let areYouReadyLabel: UILabel = {
        let label = UILabel()
        label.text = "잘 준비가 되셨나요🤔"
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(24))
        label.textColor = .white
        return label
    }()
    private lazy var areYouReadyButton: UIButton = {
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
        analyzeStreamInputs()
    }
    
    
    // MARK: - selector
    @objc func startObserving() {
        changeLabel(from: areYouReadyLabel, to: "잘자요😴")
    }
    
    
    // MARK: - functions
    func changeLabel(from label: UILabel, to text: String) {
        let duration = 1.5
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve) {
            label.text = text
        }
    }
    
    func analyzeStreamInputs() {
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
    
    func stopAnalysis() {
        audioEngine.stop()
    }
    
    
    // MARK: - configures
    private func configureAddSubViews() {
        view.backgroundColor = .systemBackground
        view.addSubViews(areYouReadyLabel,
                         areYouReadyButton)
    }
    
    private func configureConstraints() {
        areYouReadyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            areYouReadyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            areYouReadyLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        areYouReadyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            areYouReadyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            areYouReadyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            areYouReadyButton.widthAnchor.constraint(equalToConstant: Size.width),
            areYouReadyButton.heightAnchor.constraint(equalToConstant: Size.height)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .black
    }
    
    private func configureMLModel() {
        snoringClassifier = try? SnoreClassification()
    }
}
