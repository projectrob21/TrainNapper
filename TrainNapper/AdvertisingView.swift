//
//  AdvertisingView.swift
//  TrainNapper
//
//  Created by Robert Deans on 2/3/17.
//  Copyright © 2017 Robert Deans. All rights reserved.
//

import UIKit
import GoogleMobileAds


class AdvertisingView: UIView {
    
    var bannerView: GADBannerView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        bannerView = GADBannerView()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        bannerView.load(request)
    }
    
    func configure() {
        
    }
    
    func constrain() {
        
    }
}
