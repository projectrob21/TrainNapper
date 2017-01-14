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
    lazy var searchButton = UIButton()
    lazy var lirrButton = UIButton()
    lazy var metroNorthButton = UIButton()
    lazy var njTransitButton = UIButton()
    lazy var searchView = UIView()

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
        
        searchButton.setTitle("🔎", for: .normal)
        lirrButton.setTitle("LIRR", for: .normal)
        metroNorthButton.setTitle("Metro North", for: .normal)
        njTransitButton.setTitle("NJ Transit", for: .normal)
        
        let buttonsArray = [lirrButton, metroNorthButton, njTransitButton]
        
        for button in buttonsArray {
            button.backgroundColor = UIColor.blue
            button.layer.cornerRadius = 15
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        }
        
        
    }
    
    func constrain() {

        
        addSubview(searchButton)
        searchButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(8)
        }
        
        stackView.addArrangedSubview(lirrButton)
        stackView.addArrangedSubview(metroNorthButton)
        stackView.addArrangedSubview(njTransitButton)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.trailing.equalToSuperview().offset(-5)
            $0.leading.equalTo(searchButton.snp.trailing)
        }
        
        addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(searchButton.snp.trailing)
            
        }
        searchView.backgroundColor = UIColor.purple

    }
    
}
