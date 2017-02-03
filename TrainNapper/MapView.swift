//
//  MapView.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import GoogleMobileAds

class MapView: UIView {
    
    // MARK: Properties
    
    var camera: GMSCameraPosition!
    var stationsMap: GMSMapView!
    
    lazy var filterView = FilterView()
    weak var filterBranchesDelegate: FilterBranchesDelegate?
    
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
    
    
    // MARK: View Configuration
    func configure() {
        camera = GMSCameraPosition.camera(withLatitude: 40.7485, longitude: -73.9854, zoom: 8)
        stationsMap = GMSMapView.map(withFrame: .zero, camera: camera)
        stationsMap.isMyLocationEnabled = true
        stationsMap.settings.myLocationButton = true
        stationsMap.mapType = kGMSTypeNormal
        
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        stationsMap.padding = mapInsets
        
        for button in filterView.buttonsArray {
            button.addTarget(self, action: #selector(filterBranches(_:)), for: .touchUpInside)
        }
        
    }
    
    // MARK: View Constraints
    func constrain() {
        
        addSubview(stationsMap)
        stationsMap.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(stationsMap.snp.top).offset(-132)
            $0.height.equalTo(44)
            
        }
    }
    
    func filterBranches(_ sender: UIButton) {
        filterBranchesDelegate?.filterBranches(sender: sender)
    }
    
}

extension MapView: AddToMapDelegate, GetMapViewDelegate {
    
    func addStationsToMap(stations: [GMSMarker]) {
        stationsMap.clear()
        for marker in stations {
            marker.map = stationsMap
        }
    }
    
    func getInfoForMap() -> GMSMapView {
        return stationsMap
    }
    
}

