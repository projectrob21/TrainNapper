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

    
    var alarmsTableView: UITableView!
    var backgroundView: UIImageView!
    
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
        alarmsTableView = UITableView()
        alarmsTableView.separatorColor = UIColor.clear
        alarmsTableView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        alarmsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        
        var backgroundImage = #imageLiteral(resourceName: "backgroundImage")
        
        backgroundView = UIImageView(frame: CGRect(origin: CGPoint.init(x: -400, y: -100), size: backgroundImage.size))
        backgroundView.image = backgroundImage

        
//        backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundImage"))

        
    }
    
    func constrain() {
        addSubview(backgroundView)
//        backgroundView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
        addSubview(alarmsTableView)
        alarmsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
