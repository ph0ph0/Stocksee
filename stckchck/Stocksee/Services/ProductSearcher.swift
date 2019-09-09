//
//  ProductSearcher.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import AlgoliaSearch

enum Result<T> {
    case Success(T)
    case Error(String)
}

//insert error handling tings

class ProductSearcher {
    
    let query = Query()
    var productIndex: Index!
    private var searchID = 0
    private var displayedSearchID = -1
    private var loadedPage: UInt = 0
    var nbPages: UInt = 0
    var numberOfProducts = 0
    let nbOfProductsPerPage: UInt = 30
    
    typealias searchClosure = (Result<[Product]>) -> ()
    
    func searchAlgolia(around location: (lat: Double, lng: Double), with searchText: String, within searchRadius: UInt, completionHandler completion: @escaping searchClosure) {
        
        //FirebaseAnalytics data capture point
                
        query.hitsPerPage = nbOfProductsPerPage
        query.aroundPrecision = 50
        query.aroundRadius = .explicit(searchRadius)
        query.getRankingInfo = true
        query.aroundLatLng = LatLng(lat: location.lat, lng: location.lng)
        query.query = searchText
        
        if (query.filters == nil || query.filters == "") && searchText == "" {
            print("deadBeef PO filters are empty")
            query.filters = "NOT Meta.mfTVCShow:false"
        } else if (query.filters?.contains("NOT Meta.mfTVCShow:false"))! && searchText != "" {
            print("deadBeef PO searchText isn't empty, replacing no show flag")
            query.filters = query.filters?.replacingOccurrences(of: "NOT Meta.mfTVCShow:false", with: "")
        }
        
        print("deadBeef PO current query.filters: \(query.filters)")
        
        let currentSearchID = searchID
        
        productIndex = AlgoliaManager.sharedInstance.productsIndex
        productIndex.search(query) { [weak weakSelf = self] (jsonData, error) in
            
            guard currentSearchID > (weakSelf?.displayedSearchID)! else {
                print("deadBeef XX the newest query has already been displayed")
                completion(.Error("Error finding products in your area"))
                return
            }
            
            guard error == nil else {
                print("deadBeef XX error doing algolia search: \(String(describing: error))")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            guard let jsonData = jsonData else {
                print("deadBeef XX jsonData was either empty or poor connection")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            guard let jsonInfo = jsonData["hits"] as? [[String: AnyObject]] else {
                print("deadBeef XX failed to parse products")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            guard let nbOfPages = jsonData["nbPages"] as? UInt else {
                print("deadBeef XX failed error getting number of pages: \(String(describing: error))")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            weakSelf?.displayedSearchID = currentSearchID
            weakSelf?.loadedPage = 0
            
            weakSelf?.numberOfProducts = jsonData["nbHits"] as! Int
            
            print("deadBeef number of products found: \(String(describing: weakSelf?.numberOfProducts))")
            
            weakSelf?.nbPages = nbOfPages
            print("deadBeef nbOfPages: \(nbOfPages)")
            
            var filteredProducts: [Product] = []
            for product in jsonInfo {
                guard let castProduct = Product(json: product) else {
                    continue
                }
                print("deadBeef VV product distance: \((castProduct.distance!) / 1000)")
                print("deadBeef VV product geo: \(String(describing: castProduct._geoloc))")
                filteredProducts.append(castProduct)
            }
            
            DispatchQueue.main.async {
                completion(.Success(filteredProducts))
                weakSelf?.searchID += 1
                print("deadBeef XX searchQuery was: \(searchText) +=+=+=+=+=+=+=")
                print("deadBeef XX displayedSearchID \(String(describing: weakSelf?.displayedSearchID))")
                print("deadBeef XX currentSearchID: \(String(describing: currentSearchID))")
                print("deadBeef XX searchID query: \(String(describing: weakSelf?.searchID)) +=+=+=+=+=+=+=++")
            }
        }
    }
    
    func loadMore(completionHandler completion: @escaping searchClosure) {
        
        let nextQuery = Query(copy: query)
        loadedPage += 1
        let pageToLoad: UInt = loadedPage
        nextQuery.page = pageToLoad
        
        guard pageToLoad <= nbPages else {
            print("deadBeef loaded all pages")
            completion(.Error("deadBeef loaded all pages, terminating search"))
            return
        }
        
        //FirebaseAnalytics data capture point
        
        productIndex.search(nextQuery) { [weak weakSelf = self] (jsonData, error) in
            
            guard nextQuery.query == weakSelf?.query.query || error == nil else {
                print("deadBeef query has changed or error: \(String(describing: error))")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            print("deadBeef fetching page \(pageToLoad)")
            
            guard let jsonData = jsonData else {
                print("deadBeef jsonData was either empty or poor connection")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            guard let jsonInfo = jsonData["hits"] as? [[String: AnyObject]] else {
                print("deadBeef failed to get hits")
                completion(.Error("Error finding products in your area, please move location and try again"))
                return
            }
            
            weakSelf?.numberOfProducts = jsonData["nbHits"] as! Int
            
            var additionalProducts: [Product] = []
            for product in jsonInfo {
                guard let castProduct = Product(json: product) else {
                    print("deadBeef couldnt cast product for additional products")
                    continue
                }
                additionalProducts.append(castProduct)
            }
            
            DispatchQueue.main.async {
                completion(.Success(additionalProducts))
                print("deadBeef XX searchID nextQuery: \(String(describing: weakSelf?.searchID))")
            }
        }
    }
}
























