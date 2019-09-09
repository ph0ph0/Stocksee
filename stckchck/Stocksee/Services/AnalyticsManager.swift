//
//  AnalyticsManager.swift
//  stckchck
//
//  Created by Pho on 01/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//
//List of data capture Functions:
// sendLoginEventToAnalytics
// sendLoginFailureEventToAnalytics
// sendSignUpEventToAnalytics
// sendLogoutEventToAnalytics

// sendSearchEventToanalytics
// sendGeoRadiusDidChangeEventToAnalytics
// sendProductDetailViewedEventToanalytics
// sendPhoneButtoneTappedEventToAnalytics
// sendInstagramEventTapped
// sendDestinationReachedEvent

// sendProductLikedEvent
// sendProductUnlikedEvent

// sendIncompleteUserInfoEvent
//

import Foundation
import Firebase
import Crashlytics

class AnalyticsManager: NSObject {
    
    static let sharedInstance = AnalyticsManager()
    override private init(){}
    
    //MARK: Login/SignUp/Logout functions
    
    func sendLogInEventToAnalytics(loggedInVia: String, userLocation: (lat: Double, lng: Double)?) {
        
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (LogInEvent)")
            return
        }
        
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        let customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "LoggedInVia" : loggedInVia,
            "UserLocation" : userLocationString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        Answers.logLogin(withMethod: loggedInVia, success: true, customAttributes: customAttributes)
        Analytics.logEvent(AnalyticsEventLogin, parameters: customAttributes)
    }
    
    func sendLogInFailureEventToAnalytics(loginFailureReason: String, loggedInVia: String, userLocation: (lat: Double, lng: Double)?) {
    
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (LogInFailureEvent)")
            return
        }
        
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        let customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "LoginFailureReason" : loginFailureReason,
            "LoggedInVia" : loggedInVia,
            "UserLocation" : userLocationString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        Answers.logLogin(withMethod: loggedInVia, success: false, customAttributes: customAttributes)
        Analytics.logEvent(AnalyticsEventLogin, parameters: customAttributes)
    }
    
    func sendSignUpEventToAnalytics(signedUpVia: String, userLocation: (lat: Double, lng: Double)?) {
        
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (signUpEvent)")
            return
        }
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        let customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "SignedUpVia" : signedUpVia,
            "UserLocation" : userLocationString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        Answers.logSignUp(withMethod: signedUpVia, success: true, customAttributes: customAttributes)
        Analytics.logEvent(AnalyticsEventSignUp, parameters: customAttributes)
        Analytics.setUserProperty(UserInfoManager.sharedInstance.getUserSex(), forName: UserInfoProperties.Parameters.Sex.rawValue)
        //Stupid Firebase only lets you set string values for UserProperty keys...
        let stringUserBirthYear = "\(UserInfoManager.sharedInstance.getBirthYear())"
        print("deadBeef iVC_sSUETA stringUserBirthYear: \(stringUserBirthYear), type: \(type(of: stringUserBirthYear))")
        Analytics.setUserProperty(stringUserBirthYear, forName: UserInfoProperties.Parameters.BirthYear.rawValue)
        
    }
    
    func sendLogoutEventToAnalytics(userLocation: (lat: Double, lng: Double)?) {
        
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (logoutEvent)")
            return
        }
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        let customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "UserLocation" : userLocationString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        Answers.logCustomEvent(withName: "SignOut", customAttributes: customAttributes)
        Analytics.logEvent("SignOut", parameters: customAttributes)
    }
    
    //MARK: Search Functions
    
    func sendSearchEventToAnalytics(searchText: String, products: [Product], filterString: String?, geoRadius: CGFloat, userLocation: (lat: Double, lng: Double)?) {
        
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (searchEvent)")
            return
        }
        
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        var customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "GeoRadius" : geoRadius,
            "NumberOfSearchResults" : products.count,
            "UserLocation" : userLocationString,
            "FilterString" : filterString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        print("deadBeef mfTVC_dp customAttributes: \(customAttributes)")
        Answers.logSearch(withQuery: searchText, customAttributes: customAttributes)
        customAttributes[AnalyticsParameterSearchTerm] = searchText
        Analytics.logEvent(AnalyticsEventSearch, parameters: customAttributes)
        
    }
    
    func sendGeoRadiusDidChangeEventToAnalytics(geoRadius: CGFloat, userLocation: (lat: Double, lng: Double)?) {
        guard let userLocation = userLocation else {
            print("deadBeef couldnt get userLocation to send to analytics! (geoRadiusEvent)")
            return
        }
        
        let userLocationString = convertUserLocationToString(userLocation: userLocation)
        
        let customAttributes: [String: Any] = [
            UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
            UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
            UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
            "GeoRadiusChanged" : geoRadius,
            "UserLocation" : userLocationString,
            "UnixTimestamp" : getUnixTimeStamp()
        ]
        Answers.logCustomEvent(withName: "GeoRadiusChanged", customAttributes: customAttributes)
        Analytics.logEvent("GeoRadiusChanged", parameters: customAttributes)
    }
    
    //MARK: ProductDetail functions
    
    func sendProductDetailViewedEvent(product: Product?, userLocation: (lat: Double, lng: Double)?) {
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            guard let userLocation = userLocation else {
                print("deadBeef couldnt get userLocation to send to analytics! (productDetailViewedEvent)")
                return
            }
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            let userLocationString = convertUserLocationToString(userLocation: userLocation)
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            print("deadBeef analyticsManager subSubCat: \(subSubCategory), sex: \(sex)")
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size as Any,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "Meta" : meta,
                "UserLocation" : userLocationString,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            Answers.logCustomEvent(withName: "ProductDetailViewed", customAttributes: customAttributes)
            Analytics.logEvent("ProductDetailViewed", parameters: customAttributes)
            
        }
    }
    
    func sendPhoneButtonTappedEvent(product: Product?) {
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            //Didn't include userLocation in this or instagramButtonTapped as the userLocation has to be passed through too many vC's, leading to potential bugs and unnecessary complexity.
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size as Any,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "Meta" : meta,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            Answers.logCustomEvent(withName: "PhoneButtonTapped", customAttributes: customAttributes)
            Analytics.logEvent("PhoneButtonTapped", parameters: customAttributes)
            
        }
    }
    
    func sendInstagramButtonTappedEvent(product: Product?) {
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size as Any,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "Meta" : meta,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            Answers.logCustomEvent(withName: "InstagramButtonTapped", customAttributes: customAttributes)
            Analytics.logEvent("InstagramButtonTapped", parameters: customAttributes)
            
        }
    }
    
    func sendDestinationReached(product: Product?) {
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            print("deadBeef analyticsManager subSubCat: \(subSubCategory), sex: \(sex)")
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "Meta" : meta,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            print("deadBeef DT sending analytics event for \(brand) sold by \(shopName)")
            Answers.logCustomEvent(withName: "DestinationReached", customAttributes: customAttributes)
            Analytics.logEvent("DestinationReached", parameters: customAttributes)
            
        }
    }
    
    //MARK: Liked Product Functions
    
    func sendProductLikedEvent(product: Product?, userLocation: (lat: Double, lng: Double)?) {
        
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            guard let userLocation = userLocation else {
                print("deadBeef couldnt get userLocation to send to analytics! (productLikedEvent)")
                return
            }
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            let userLocationString = convertUserLocationToString(userLocation: userLocation)
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size as Any,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UserLocation" : userLocationString,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            Answers.logCustomEvent(withName: "ProductLiked", customAttributes: customAttributes)
            Analytics.logEvent("ProductLiked", parameters: customAttributes)
        }
    }
    
    func sendProductUnlikedEvent(product: Product?, userLocation: (lat: Double, lng: Double)?) {
        
        if let brand = product?.brand, let model = product?.model, let objectID = product?.objectID, let shopName = product?.shopName, let shopID = product?.shopID, let geoLoc = product?._geoloc, let price = product?.price, let distance = product?.distance, let category = product?.category, let meta = product?.meta {
            
            guard let userLocation = userLocation else {
                print("deadBeef couldnt get userLocation to send to analytics! (productUnlikedEvent)")
                return
            }
            
            let geolocString = convert_geolocToString(_geoloc: geoLoc)
            let userLocationString = convertUserLocationToString(userLocation: userLocation)
            
            //Metadata (Include other metadata such as colour, etc alongside size!!!)
            let size = product?.size
            
            let subCategory = meta["SubCategory"] as? String ?? nil
            let subSubCategory = meta["SubSubCategory"] as? String ?? nil
            let sex = meta["Sex"] as? String ?? nil
            let mfTVCShow = meta["mfTVCShow"] as? String ?? nil
            
            let customAttributes: [String: Any] = [
                UserInfoProperties.Parameters.BirthYear.rawValue : UserInfoManager.sharedInstance.getBirthYear(),
                UserInfoProperties.Parameters.Sex.rawValue : UserInfoManager.sharedInstance.getUserSex(),
                UserInfoProperties.Parameters.uid.rawValue : UserInfoManager.sharedInstance.getUID(),
                "Brand" : brand,
                "Model" : model,
                "Size" : size as Any,
                "objectID" : objectID,
                "ShopName" : shopName,
                "ShopID" : shopID,
                "geoloc" : geolocString,
                "Price" : price,
                "distance" : distance,
                "Category" : category,
                "Meta" : meta,
                "ProductSex": sex,
                "SubCategory": subCategory,
                "SubSubCategory": subSubCategory,
                "mfTVCShow": mfTVCShow,
                "UserLocation" : userLocationString,
                "UnixTimestamp" : getUnixTimeStamp()
            ]
            print("deadBeef pdVC_vWA customAttributes: \(customAttributes)")
            Answers.logCustomEvent(withName: "ProductUnliked", customAttributes: customAttributes)
            Analytics.logEvent("ProductUnliked", parameters: customAttributes)
        }
    }
    
    //MARK: Error functions
    
    func sendIncompleteUserInfoError(uid: String?) {
        guard let uid = uid else {
            print("deadBeef failed to get userID to send error to analytics")
            return
        }
        let customAttributes: [String: Any] = [
            
            "uid": uid,
            "UnixTimestamp" : getUnixTimeStamp()
        
        ]
        print("deadBeef user with incomplete details is: \(uid)")
        Answers.logCustomEvent(withName: "IncompleteUserInfo", customAttributes: customAttributes)
        Analytics.logEvent("IncompleteUserInfo", parameters: customAttributes)
    }
    
    //MARK: Helper functions
    
    // geo data myust be converted to string to send to big query
    
    func convert_geolocToString(_geoloc: [String: AnyObject]) -> String? {
        
        let geolocation = _geoloc
        guard let lat = geolocation["lat"] else {
            print("deadBeef couldnt get lat of geoloc for analytics")
            return nil
        }
        guard let lng = geolocation["lng"] else {
            print("deadBeef couldnt get lng of geoloc for analytics")
            return nil
        }
        let geolocationString = "\(lat), \(lng)"
        
        return geolocationString
    }
    
    func convertUserLocationToString(userLocation: (lat: Double, lng: Double)) -> String {
        
        let geolocation = userLocation
        let lat = geolocation.lat
        let lng = geolocation.lng
        let geolocationString = "\(lat), \(lng)"
        
        return geolocationString
        
    }
    
    func getUnixTimeStamp() -> UInt64 {
        return UInt64(Date().timeIntervalSince1970)
    }
    
}
