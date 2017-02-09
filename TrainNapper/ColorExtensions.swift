//
//  ColorExtensions.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/16/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import UIKit

// MARK: Custom Colors

extension UIColor {
    public static let mainColor = UIColor(red: 16 / 255, green: 91 / 255, blue: 99 / 255, alpha: 1)
    
    public static let filterButtonColor = UIColor(red: 255 / 255, green: 211 / 255, blue: 78 / 255, alpha: 1)
    
    public static let lirrColor = UIColor(red: 69 / 255, green: 178 / 255, blue: 157 / 255, alpha: 1)
    
    public static let metroNorthColor = UIColor(red: 51 / 255, green: 77 / 255, blue: 92 / 255, alpha: 1)
    
    public static let njTransitColor = UIColor.purple
    
}

// MARK: Gradients
extension CAGradientLayer {
    convenience init(_ colors: [UIColor]) {
        self.init()
        self.colors = colors.map { $0.cgColor }
    }
}

extension CALayer {
    public static func makeGradient(firstColor: UIColor, secondColor: UIColor) -> CAGradientLayer {
        let backgroundGradient = CAGradientLayer()
        
        backgroundGradient.colors = [firstColor.cgColor, secondColor.cgColor]
        backgroundGradient.locations = [0, 1]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0, y: 1)
        
        return backgroundGradient
    }
}
