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
    var napperAlarmsDelegate: NapperAlarmsDelegate?
    let napper = sharedDelegate.napper
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        constrain()
    }
    
    func configure() {
        
        alarmsTableView = UITableView()
        alarmsTableView.delegate = self
        alarmsTableView.dataSource = self
        
        alarmsTableView.separatorColor = UIColor.clear
        alarmsTableView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        alarmsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        
        let backgroundImage = #imageLiteral(resourceName: "backgroundImage")
        
        backgroundView = UIImageView(frame: CGRect(origin: CGPoint.init(x: -400, y: -100), size: backgroundImage.size))
        backgroundView.image = backgroundImage
        
    }
    
    func constrain() {
        addSubview(backgroundView)

        addSubview(alarmsTableView)
        alarmsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

// MARK: Tableview Delegate
extension AlarmsListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return napper.destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        let station = napper.destinations[indexPath.row].name
        
        cell.textLabel?.text = station
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let station = self.napper.destinations[indexPath.row]

            self.napperAlarmsDelegate?.removeAlarm(station: station)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        return [delete]
    }
    
}
