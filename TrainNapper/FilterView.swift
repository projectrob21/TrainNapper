//
//  FilterView.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/10/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FilterView: UIView {
    
    lazy var stackView = UIStackView()
    lazy var lirrButton = UIButton()
    lazy var metroNorthButton = UIButton()
    lazy var njTransitButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        configure()
        constrain()
    }
    
    func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center
        
        lirrButton.backgroundColor = UIColor.blue
        lirrButton.layer.cornerRadius = 18
        lirrButton.titleLabel?.adjustsFontSizeToFitWidth = true
        lirrButton.setTitle("LIRR", for: .normal)
        
        metroNorthButton.backgroundColor = UIColor.blue
        metroNorthButton.layer.cornerRadius = 18
        metroNorthButton.titleLabel?.adjustsFontSizeToFitWidth = true
        metroNorthButton.setTitle("Metro North", for: .normal)
        
        njTransitButton.backgroundColor = UIColor.blue
        njTransitButton.layer.cornerRadius = 18
        njTransitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        njTransitButton.setTitle("NJ Transit", for: .normal)
        
    }
    
    func constrain() {
        stackView.addArrangedSubview(lirrButton)
        stackView.addArrangedSubview(metroNorthButton)
        stackView.addArrangedSubview(njTransitButton)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsetsMake(15, 8, 15, 8))
        }
    }
    
}
