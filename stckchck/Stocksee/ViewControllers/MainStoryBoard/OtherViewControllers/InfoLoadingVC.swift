//
//  InfoLoadingVC.swift
//  Stocksee
//
//  Created by Pho on 24/06/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import UIKit

class InfoLoadingVC: UIViewController {
    
    var loadingAnimation = LoadingAnimation()
    var uid: String?
    var registeredViaFB = false
    var userLocation: (lat: Double, lng: Double)?
    
    //When we dismiss the infoVC by walking back up the presentingVC's, vWA is called in here. As such, we need a boolean to say whether or not the RC load has been done and we have already segued from here. Otherwise, when the infoVC is dismissed, vWA in here is called and we segue back to the infoVC, which is not what we want.
    var fetchCompleteAndSegueDone = false
    
    func showInfoVC() {
        print("deadBeef RC_ segueing to infoVC")
        fetchCompleteAndSegueDone = true
        performSegue(withIdentifier: "LoadingToInfoSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoadingToInfoSegue" {
            print("deadBeef RC_ segue from loading to info; uid: \(uid), regViaFB: \(registeredViaFB), _geoloc: \(userLocation)")
                let destination = segue.destination as? InfoViewController
                destination?.uid = uid
                destination?.registeredViaFB = registeredViaFB
                destination?.userLocation = userLocation
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("deadBeef RC_ view will appear, current RC fetch done?: \(RemoteConfigManager.sharedInstance.fetchComplete)")
        
        if RemoteConfigManager.sharedInstance.fetchComplete && !fetchCompleteAndSegueDone {
            print("deadBeef RC_ infoLoadingVC, RC fetch complete so segueing to infoVC")
            self.showInfoVC()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingAnimation.display()
        view.addSubview(loadingAnimation)
        
        RemoteConfigManager.sharedInstance.loadingDoneCallback = showInfoVC
        
        print("deadBeef RC_ current status of RC fetch complete?: \(RemoteConfigManager.sharedInstance.fetchComplete)")
        
        
        print("deadBeef InfoLoading VC uid, regViaFB, userLocation: \(self.uid), \(self.registeredViaFB), \(self.userLocation)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        loadingAnimation.stop()
    }
    
}
