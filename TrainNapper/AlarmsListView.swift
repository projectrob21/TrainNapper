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

    
    lazy var alarmsTableView = UITableView()
    lazy var imageView = UIView()
    
    
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
        alarmsTableView.separatorColor = UIColor.clear
        alarmsTableView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundImage"))
        
    }
    
    func constrain() {
        
        
        addSubview(alarmsTableView)
        alarmsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
