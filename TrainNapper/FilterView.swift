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
import GoogleMaps

protocol FilterViewDelegate: class {
    func addStationsToMap(stations: [GMSMarker])
}

class FilterView: UIView, UISearchBarDelegate {
    
    lazy var stackView = UIStackView()
    lazy var searchButton = UIButton()
    lazy var lirrButton = UIButton()
    lazy var metroNorthButton = UIButton()
    lazy var njTransitButton = UIButton()
    lazy var searchView = UIView()
    var gradient: CAGradientLayer!
    var showFilter = false

    lazy var searchBar = UISearchBar()
    var showSearch = false

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        configure()
        constrain()
    }
    
    func configure() {
        backgroundColor = UIColor.clear

        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center
        
        searchButton.setTitle("🔎", for: .normal)
        lirrButton.setTitle("LIRR", for: .normal)
        metroNorthButton.setTitle("Metro North", for: .normal)
        njTransitButton.setTitle("NJ Transit", for: .normal)
        
        let buttonsArray = [lirrButton, metroNorthButton, njTransitButton]
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        for button in buttonsArray {
            button.backgroundColor = UIColor.filterButtonColor
            button.layer.cornerRadius = 15
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
//            button.addTarget(self, action: #selector(filterBranches), for: .touchUpInside)
        }
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Destination"
        searchBar.delegate = self
        searchBar.endEditing(true)

        
        
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
        
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

    }
    
    
    func setupGradientLayer() {
        let color2 = UIColor(red: 141/255.0, green: 191/255.9, blue: 103/255.0, alpha: 1.0)
        let backgroundGradient = CALayer.makeGradient(firstColor: UIColor.lirrColor, secondColor: color2)
        backgroundGradient.frame = self.frame
        self.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func searchButtonTapped() {
        showSearch = !showSearch
        
        if showSearch {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                
                self.searchView.snp.remakeConstraints {
                    $0.top.bottom.trailing.equalToSuperview()
                    $0.leading.equalTo(self.searchButton.snp.trailing)
                }
                
                self.searchBar.snp.remakeConstraints {
                    $0.edges.equalToSuperview()
                }
                
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                
                self.searchView.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.leading.equalTo(self.searchButton.snp.trailing)
                }
                self.searchBar.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.leading.equalTo(self.searchButton.snp.trailing)
                }
                self.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    
}
