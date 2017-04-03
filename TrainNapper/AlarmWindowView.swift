//
//  AlarmMarkerWindow.swift
//  TrainNapper
//
//  Created by Robert Deans on 3/31/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import Foundation
import UIKit

class AlarmWindowView: UIView {
    

    
    var nameTextField: UITextField!
    var cityTextField: UITextField!
    var editUserButton: UIButton!
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(frame: CGRect) { super.init(frame: frame) }
    
    convenience init() {
        let width = UIScreen.main.bounds.width / 1.2
        let height = width
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        configure()
        constrain()
    }
    

    


    
    func configure() {
        backgroundColor = UIColor.purple
        
        layer.cornerRadius = 5
        nameTextField = UITextField()
        nameTextField.text = "NAME"
        nameTextField.backgroundColor = UIColor.lightGray
        
        cityTextField = UITextField()
        cityTextField.text = "NOTES"
        cityTextField.backgroundColor = UIColor.lightGray
        
        editUserButton = UIButton()
        editUserButton.backgroundColor = UIColor.purple
        editUserButton.setTitle("Update", for: .normal)

        
    }
    
    func constrain() {
        

        
        addSubview(nameTextField)
        nameTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.top.equalToSuperview().offset(50)
        }
        
        addSubview(cityTextField)
        cityTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.top.equalTo(nameTextField.snp.bottom).offset(5)
        }
        
        addSubview(editUserButton)
        editUserButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(cityTextField.snp.bottom).offset(10)
        }
        
        
        
    }
    
}
