//
//  UserInfoManager.swift
//  stckchck
//
//  Created by Pho on 26/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import FirebaseAuth

struct UserInfoProperties {
    
    enum Parameters: String {
        case BirthYear = "BirthYear"
        case Sex = "Sex"
        case uid = "uid"
    }
    
}

class UserInfoManager: NSObject {
    
    static let sharedInstance = UserInfoManager()
    override private init(){}
    
    var propertiesSet: Bool = false
    var uID: String?
    
    private (set)var userBirthYear: Int = 0
    
    private var userSex: String = "N/A"
    
    private var uid: String? = nil
    
    func getBirthYear() -> Int {
        return userBirthYear
    }
    
    func getUserSex() -> String {
        return userSex
    }
    
    func getUID() -> String? {
        return uid
    }
    
    //Called in vWA if uid from Firebase isn't nil and properties aren't already set, also in dismiss of iVC
    func setUserInfo(userBirthYear: Int, userSex: String, uid: String) {
        self.userBirthYear = userBirthYear
        self.userSex = userSex
        self.uid = uid
        self.propertiesSet = true
        
        print("deadBeef UserInfoManager setUserInfo, uid: \(String(describing: self.uid)), bY: \(self.userBirthYear), sex: \(self.userSex)")
    }
    
    //Called in logout
    func resetUserInfo() {
        self.userBirthYear = 0
        self.userSex = "N/A"
        self.uid = nil
        self.propertiesSet = false
        
        print("deadBeef UserInfoManager RESETUserInfo!, uid: \(String(describing: self.uid)), bY: \(self.userBirthYear), sex: \(self.userSex)")
    }
    
}
