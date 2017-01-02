//
//  MapView.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SnapKit

class MapView: UIView {
    
    // MARK: Properties
    var camera: GMSCameraPosition!
    var stationsMap: GMSMapView!
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(frame: CGRect) { super.init(frame: frame) }
    convenience init() { self.init(frame: CGRect.zero); configure(); constrain() }
    
    
    // MARK: View Configuration
    func configure() {
        camera = GMSCameraPosition.camera(withLatitude: 40.7485, longitude: -73.9854, zoom: 8)
        stationsMap = GMSMapView.map(withFrame: .zero, camera: camera)
        stationsMap.isMyLocationEnabled = true
        stationsMap.settings.myLocationButton = true
        stationsMap.mapType = kGMSTypeNormal
        
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        stationsMap.padding = mapInsets
        
        
    }
    
    // MARK: View Constraints
    func constrain() {

        addSubview(stationsMap)
        stationsMap.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}
