//
//  WalkthroughLaunchService.swift
//  stckchck
//
//  Created by Pho on 13/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation

//For testing (always first launch) use:
//let alwaysFirstLaunch = FirstLaunch.alwaysFirst()
//if alwaysFirstLaunch.isFirstLaunch {
//    // will always execute
//}

final class WalkthroughLaunchService {
    
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
        
    }
    
}

extension WalkthroughLaunchService {
    
    static func alwaysFirstLaunch() -> WalkthroughLaunchService {
         return WalkthroughLaunchService(getWasLaunchedBefore: { return false },
                                        setWasLaunchedBefore: {_ in})
        
    }
    
}




