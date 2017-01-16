//
//  AlarmsListView.swift
//  TrainNapper
//
//  Created by Robert Deans on 1/16/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import UIKit
import SnapKit

class AlarmsListView: UIView {

    
    let alarmsTableView = UITableView()
    
    
    // MARK: Initialization
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
        
    }
    
    func constrain() {
        addSubview(alarmsTableView)
        alarmsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
