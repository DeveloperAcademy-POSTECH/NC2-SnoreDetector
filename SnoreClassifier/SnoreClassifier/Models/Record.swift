//
//  Record.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation

struct Record {

    enum soundLevel: String {
        case low = "조용한 사무실"         // ~40dB
        case medium = "전화벨소리"        // 50~70dB
        case high = "소음이 심한 공장 안"   // 70dB~
    }
    
    let decibel: Int
    let date: String
    var similarSound: soundLevel

}

