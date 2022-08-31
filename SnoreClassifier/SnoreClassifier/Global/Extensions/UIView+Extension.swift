//
//  UIView+Extension.swift
//  SnoreClassifier
//
//  Created by 이성민 on 2022/08/30.
//

import Foundation
import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
