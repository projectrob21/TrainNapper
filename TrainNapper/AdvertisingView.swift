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
    var request: GADRequest!

    convenience init() {
        self.init(frame: CGRect.zero)
        bannerView = GADBannerView()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.rootViewController = self
        request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        bannerView.load(request)
        
        
    }
    

    
    
}
