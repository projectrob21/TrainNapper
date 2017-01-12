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
    lazy var filterLabel = UILabel()
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
        backgroundColor = UIColor.lightGray
        
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.alignment = .center
        
        filterLabel.text = "Filter:"
        
        lirrButton.backgroundColor = UIColor.blue
        lirrButton.setTitle("LIRR", for: .normal)
        
        metroNorthButton.backgroundColor = UIColor.blue
        metroNorthButton.setTitle("Metro North", for: .normal)
        
        njTransitButton.backgroundColor = UIColor.blue
        njTransitButton.setTitle("NJ Transit", for: .normal)
        
    }
    
    func constrain() {
        stackView.addArrangedSubview(filterLabel)
        stackView.addArrangedSubview(lirrButton)
        stackView.addArrangedSubview(metroNorthButton)
        stackView.addArrangedSubview(njTransitButton)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(UIEdgeInsetsMake(15, 15, 15, 15))
        }
    }
    
}
