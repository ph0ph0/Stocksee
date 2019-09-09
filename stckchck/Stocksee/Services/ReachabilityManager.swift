//
//  ReachabilityManager.swift
//  stckchck
//
//  Created by Pho on 14/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityManager: NSObject {
    
    //Inject notification center instance
    private let notificationCenter: NotificationCenter
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    //create a singleton instance
    static let sharedInstance = ReachabilityManager()
    
    //Reachability is a class that defines the different states of the network
    var reachability = Reachability()
    
    //Tracks if network is reachable. If reachability is not equal to .none, then reachable via wifi or cellular
    var networkIsReachable: Bool {
        return ReachabilityManager.sharedInstance.reachability?.connection != .none
    }
    
    //Tracks current network status
    lazy var reachabilityStatus: Reachability.Connection = .none
    
    //Our array of objects that are listening for notifications
    var listeners = [NetworkStatusListener]()
    
    //Allows us to add the object to the listener array when vC appears
    func addListener(listener: NetworkStatusListener) {
        listeners.append(listener)
    }
    
    //Allows us to remove the object to the listener array when vC disappears
    func removeListener(listener: NetworkStatusListener) {
        listeners = listeners.filter { $0 !== listener }
    }
    
    var counter = 0
    
    //Is called each time the network status changes
    @objc func networkStatusChanged(notification: Notification) {
        counter += 1
        print("deadBeef rM no. of listeners: \(listeners.count), counter: \(counter)")
        
        let bgQueue = DispatchQueue.global(qos: .userInitiated)
        bgQueue.async { [weak weakSelf = self] in
            let reachability = notification.object as! Reachability
            
            switch reachability.connection {
            case .none:
                print("deadBeef rM network became unreachable")
                weakSelf?.reachabilityStatus = .none
            case .cellular:
                print("deadBeef rM network became reachable via cellular")
                weakSelf?.reachabilityStatus = .cellular
            case .wifi:
                print("deadBeef rM network became reachable via wifi")
                weakSelf?.reachabilityStatus = .wifi
            }
            
            for listener in weakSelf!.listeners {
                listener.networkStatusDidChange(status: weakSelf!.reachabilityStatus)
            }
        }
    }
    
    func startMonitoringNetworkReachability() {
        
        notificationCenter.addObserver(self,
                                        selector: #selector(self.networkStatusChanged(notification:)),
                                        name: .reachabilityChanged,
                                        object: reachability)
        
        do{
            try reachability!.startNotifier()
        } catch {
            print("deadBeef couldnt start monitoring network reachability")
        }
    }
    
    func stopMonitoringNetworkReachability() {
        
        reachability?.stopNotifier()
        notificationCenter.removeObserver(self,
                                          name: .reachabilityChanged,
                                          object: reachability)
    }
}








