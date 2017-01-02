//
//  MarkerWindowView.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/26/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import Foundation
import UIKit

class MarkerWindowView: UIView {
    
    lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    lazy var stationLabel = UILabel()
    lazy var setAlarmButton = UIButton()
    
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(frame: CGRect) { super.init(frame: frame) }
    convenience init() {
        let width = UIScreen.main.bounds.width / 1.2
        let height = width / 3
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        configure()
        constrain()
    }
    
    func configure() {
        layer.cornerRadius = 10
        
        stationLabel.font = UIFont(name: "HelveticaNeue", size: 34)
        
        setAlarmButton.setTitle("Set Alarm", for: .normal)
        setAlarmButton.titleLabel?.textColor = UIColor.white
        setAlarmButton.backgroundColor = UIColor.blue
    }
    
    func constrain() {
        
        addSubview(blurView)
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blurView.addSubview(stationLabel)
        stationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        }
        
        addSubview(setAlarmButton)
        setAlarmButton.snp.makeConstraints {
            $0.centerX.width.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(4)
            $0.bottom.equalToSuperview().offset(-10)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        
        
        
    }
    
}
