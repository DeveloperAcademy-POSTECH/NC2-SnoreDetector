//
//  Date+Extension.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/31.
//

import Foundation

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
