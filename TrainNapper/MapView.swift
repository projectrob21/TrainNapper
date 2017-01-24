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
import GoogleMobileAds

class MapView: UIView {
    
    // MARK: Properties
    
    var camera: GMSCameraPosition!
    var stationsMap: GMSMapView!
    var advertisingView: GADBannerView!
    
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
        
        advertisingView = GADBannerView()
        advertisingView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        for button in filterView.buttonsArray {
            button.addTarget(self, action: #selector(filterBranches(_:)), for: .touchUpInside)
        }
        
    }
    
    // MARK: View Constraints
    func constrain() {

        addSubview(advertisingView)
        advertisingView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(10)
        }
        
        addSubview(stationsMap)
        stationsMap.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(advertisingView.snp.top)
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

extension MapView: AddToMapDelegate {
    
    func addStationsToMap(stations: [GMSMarker]) {
        stationsMap.clear()
        for marker in stations {
            marker.map = stationsMap
        }
    }
}

