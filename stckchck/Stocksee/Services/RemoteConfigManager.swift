//
//  RemoteConfigManager.swift
//  Stocksee
//
//  Created by Pho on 24/06/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import Firebase

enum ValueKey: String {
    case BYandSexAreCompulsory
}

class RemoteConfigManager {
    
    static let sharedInstance = RemoteConfigManager()
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        
        let appDefaults: [String: Any?] = [
        
            ValueKey.BYandSexAreCompulsory.rawValue : false
        
        ]
        
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
        
    }
    
    func fetchCloudValues() {
        
        //Remove 0 value in production, should be at least 12hours (43200)!!!
        let fetchDuration: TimeInterval = 43200
        //activateDebugMode()
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { (status, error) in
            
            if let error = error {
                print("deadBeef RC_ error getting remote values: \(error)")
                return
            }
            
            RemoteConfig.remoteConfig().activateFetched()
            print("deadBeef RC_ retrieved values from the cloud")
            
            let currentRCStatus = RemoteConfig.remoteConfig()
                .configValue(forKey: "BYandSexAreCompulsory")
                .boolValue ?? false
            
            print("deadBeef RC_ current RC status: \(currentRCStatus)")
            
            self.fetchComplete = true
            self.loadingDoneCallback?()
        }
        
    }
    
    func activateDebugMode() {
        RemoteConfig.remoteConfig().configSettings = RemoteConfigSettings(developerModeEnabled: true)
        
    }
    
    func shouldShowBYandSexAsCompulsory(forKey key: ValueKey) -> Bool {
        let RC_Bool = RemoteConfig.remoteConfig()[key.rawValue].boolValue ?? false
        return RC_Bool
    }
    
}
