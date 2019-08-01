//
//  AppearanceHelper.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 8/1/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import Foundation
import UIKit

enum AppearanceHelper {
    
    static var floridaOrange = UIColor(red: 216.0/255.0, green: 137.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static var specialBlue = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    static var darkBlue = UIColor(red: 7.0/255.0, green: 26.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    static var customYellow = UIColor(red: 254.0/255.0, green: 209.0/255.0, blue: 88.0/255.0, alpha: 1.0)
    
    static func customFont(with textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: "AmericanTypewriter", size: pointSize)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font) // scales the font
    }
    
    static func setColorAppearance() {
        
        UIButton.appearance().tintColor = specialBlue
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: customFont(with: .title1, pointSize: 35)]
        UINavigationBar.appearance().largeTitleTextAttributes = textAttributes
        UISearchBar.appearance().barTintColor = specialBlue
        
        
    }
}
