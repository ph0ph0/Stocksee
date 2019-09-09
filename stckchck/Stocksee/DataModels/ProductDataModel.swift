//
//  ProductDataModel.swift
//  stckchck
//
//  Created by Pho on 22/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import AlgoliaSearch
import InstantSearchCore
import IGListKit

// Usually your object would inherit from NSObject for IGListKit. I have not done this, as otherwise I cannot implement my own equatable method, which is required for the deleteLikedProduct method of the pVC.
class Product {
    
    var GTIN: Double?
    var brand: String?
    var model: String?
    var desc: String?
    var price: Double?
    var size: [String]?
    var category: String?
    var shopName: String?
    var shopID: String?
    var stockLevel: Int?
    var imageURLs: [String]?
    var _geoloc: [String: AnyObject]?
    var distance: Float? //needs computation
    var objectID: String?
    var likedBy: [String]?
    var instagramProfile: String?
    var shopPhoneNumber: String?
    var openingTimes: String?
    var productCode: String?
    var meta: [String: AnyObject]?
    
    init?(json: [String: Any]) {
        
        self.GTIN = json["GTIN"] as? Double
        self.brand = json["Brand"] as? String
        self.model = json["Model"] as? String
        
        //This may cause bugs in the descriptions... Becuase the products have been stored as JSON, backslashes are present where double quotes are to escape them. For example, when inches are used for measurement ie a 32" waist. We need to remove these and replace them with no space.
        let description = json["Desc"] as? String
        self.desc = description?.replacingOccurrences(of: "\\", with: "")
        
        self.price = json["Price"] as? Double
        self.size = json["Size"] as? [String]
        self.category = json["Category"] as? String
        self.shopName = json["ShopName"] as? String
        self.shopID = json["ShopID"] as? String
        self.stockLevel = json["StockLevel"] as? Int
        
        //URLs from the cloud contain backslashes, these need to be removed.
        guard let urls = json["ImageURLs"] as? [String] else {
            print("deadBeef no imageURLs")
            return
        }
        var imageURLs = [String]()
        for url in urls {
            let urlString = url.replacingOccurrences(of: "\\", with: "")
            imageURLs.append(urlString)
        }
        self.imageURLs = imageURLs
        
        self._geoloc = json["_geoloc"] as? [String: AnyObject]
        
        guard let rankingInfo = json["_rankingInfo"] as? [String: AnyObject] else {
            return nil
        }
        guard let location = rankingInfo["matchedGeoLocation"] as? [String: AnyObject] else {
            return nil
        }
        self.distance = location["distance"] as? Float
        
        self.objectID = json["objectID"] as? String
        self.likedBy = json["LikedBy"] as? [String]
        
        //If the product has never been liked by anyone, then the likedBy property will be nil. We must create an empty array otherwise we cannot append the current uid to it when we tap the like button
        if self.likedBy == nil {
            print("deadBeef KK creating likedBy array")
            self.likedBy = [String]()
        }
        
        self.instagramProfile = json["InstagramProfile"] as? String
        self.shopPhoneNumber = json["ShopPhoneNumber"] as? String
        self.openingTimes = json["OpeningTimes"] as? String
        self.productCode = json["ProductCode"] as? String
        self.meta = json["Meta"] as? [String: AnyObject]
        
    }
}

//THIS COULD CAUSE BUGS, I HAVE HAD TO GET RID OF IT SO WE CAN USE isEqual...
extension Product: Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.GTIN == rhs.GTIN && lhs.shopName == rhs.shopName && lhs.objectID == rhs.objectID
    }
}

extension Product: ListDiffable {

    public func diffIdentifier() -> NSObjectProtocol {
        return self as! NSObjectProtocol
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let product = object as? Product else {return false}
        let selfy = self
        guard self !== product else {return true}

        if selfy.objectID != product.objectID {
            return false
        }

        return self == product
    }
}

