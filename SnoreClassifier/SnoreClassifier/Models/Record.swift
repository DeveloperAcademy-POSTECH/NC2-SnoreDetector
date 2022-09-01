//
//  Record.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation

struct Record {
    let id: UUID = UUID()
    let recordedDate: Date = Date.now
    var fileURL: URL
}
