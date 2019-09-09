//
//  StepTwoVC.swift
//  stckchck
//
//  Created by Pho on 11/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class StepFourViewController: UIViewController {
    
    @IBOutlet weak var gotItButtonoutlet: UIButton!
    
    @IBAction func gotItButton(_ sender: Any) {
        print("deadBeef sfVC gotItButton tapped")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNavCon = mainStoryboard.instantiateViewController(withIdentifier: "MainNavCon") as! UINavigationController
        present(mainNavCon, animated: true) {
            //We want to start monitoring the reachability now so that we can find products in the mfTVC
            DispatchQueue.main.async {
                ReachabilityManager.sharedInstance.startMonitoringNetworkReachability()
            }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gotItButtonoutlet.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        let title = gotItButtonoutlet.title(for: .normal)
        let attributedTitle = NSAttributedString(string: title!, attributes: [NSAttributedStringKey.kern: 2.2])
        gotItButtonoutlet.setAttributedTitle(attributedTitle, for: .normal)
        gotItButtonoutlet.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.transition(with: self.gotItButtonoutlet,
                          duration: 2,
                          options: UIViewAnimationOptions.transitionCrossDissolve,
                          animations: {self.gotItButtonoutlet.alpha = 1}) { (success) in
                            if success {
                                print("deadBeef sfVC_vDA showed gotItButton")
                            }
        }
        
    }
    
}

