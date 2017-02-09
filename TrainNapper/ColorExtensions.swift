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
    public static let mainColor = UIColor(red: 0 / 255, green: 61 / 255, blue: 92 / 255, alpha: 1)
    
    public static let titleColor = UIColor(red: 253 / 255, green: 238 / 255, blue: 167 / 255, alpha: 1)
    
    public static let filterButtonColor = UIColor(red: 155 / 255, green: 204 / 255, blue: 147 / 255, alpha: 1)
//        UIColor(red: 255 / 255, green: 211 / 255, blue: 78 / 255, alpha: 1)
    
    public static let filterButtonBorderColor = UIColor(red: 26 / 255, green: 148 / 255, blue: 129 / 255, alpha: 1)
    
    public static let lirrColor = UIColor(red: 69 / 255, green: 178 / 255, blue: 157 / 255, alpha: 1)
    
    public static let metroNorthColor = UIColor(red: 51 / 255, green: 77 / 255, blue: 92 / 255, alpha: 1)
    
    public static let njTransitColor = UIColor.blue
    
    
    
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

let iconSize = 30
extension UIImage {
    static let njTransitIcon = #imageLiteral(resourceName: "NJ-Transit").resizedImage(newSize: CGSize(width: iconSize, height: iconSize))
    
    static let lirrIcon = #imageLiteral(resourceName: "oldLIRR").resizedImage(newSize: CGSize(width: iconSize, height: iconSize))
    
    static let metroNorthIcon = #imageLiteral(resourceName: "mta").resizedImage(newSize: CGSize(width: iconSize, height: iconSize))
    
    static let alarmClock = #imageLiteral(resourceName: "alarmclock").resizedImage(newSize: CGSize(width: iconSize, height: iconSize))
    
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    

    
}
