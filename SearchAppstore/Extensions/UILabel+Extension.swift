//
//  UILabel+Extension.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    ///set color
    func set(color: UIColor, for keyword: String) {
        guard let text = self.text else { return }
        
        let indices = text.indicesOf(string: keyword)
        let length = keyword.count
        let attributedString = NSMutableAttributedString(string: text)
        
        for index in indices {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: index, length: length))
        }
        attributedText = attributedString
    }
    
    ///set font
    func set(font: UIFont, for keyword: String) {
        guard let text = self.text else { return }
        
        let indices = text.indicesOf(string: keyword)
        let length = keyword.count
        let attributedString = NSMutableAttributedString(string: text)
        
        for index in indices {
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: index, length: length))
        }
        attributedText = attributedString
    }
}
