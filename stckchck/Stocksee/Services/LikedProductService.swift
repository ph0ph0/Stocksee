//
//  LikedProductService.swift
//  stckchck
//
//  Created by Pho on 03/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import AlgoliaSearch
import FirebaseAuth
import FirebaseFirestore
import Crashlytics
import Firebase

class LikedProductService {
    
    enum Result<T> {
        case Success(T)
        case Error(String)
    }
    
    //insert error handling tings
    
    let query = Query()
    var productIndex: Index!
    private var searchID = 0
    private var displayedSearchID = -1
    private var loadedPage: UInt = 0
    var nbPages: UInt = 0
    var numberOfProducts = 0
    let nbOfProductsPerPage: UInt = 30
    lazy var uid: String? = Auth.auth().currentUser?.uid ?? nil
    
    typealias searchClosure = (Result<[Product]>) -> ()
    typealias successClosure = (Bool) -> ()
    typealias successAndUpdateClosure = (Bool, Bool) -> ()
    
    //MARK: findLikedProduct()
    
    func findLikedProducts(around location: (lat: Double, lng: Double), completionHandler completion: @escaping searchClosure) {
        
        print("deadBeef LPS_findLikedProducts thread: \(Thread.current)")
        
        query.hitsPerPage = nbOfProductsPerPage
        query.aroundPrecision = 50
        query.getRankingInfo = true
        query.aroundLatLng = LatLng(lat: location.lat, lng: location.lng)
        query.query = uid
        
        let currentSearchID = searchID
        
        productIndex = AlgoliaManager.sharedInstance.productsIndex
        productIndex.search(query) { [weak weakSelf = self] (jsonData, error) in
            
            print("deadBeef lPS_flP displayedSearchID: \(String(describing: weakSelf?.displayedSearchID))")
            print("deadBeef lPS_flP currentSearchID: \(currentSearchID)")
            
            guard let displayedSearchID = weakSelf?.displayedSearchID else {
                print("deadBeef lPS_flP displayedSearchID was nil")
                completion(.Error("Error finding your liked products, please try again"))
                return
            }
            
            guard currentSearchID > displayedSearchID else {
                print("deadBeef the newest query has already been displayed")
                completion(.Error("Error finding your liked products, please try again"))
                return
            }
            
            guard error == nil else {
                print("deadBeef error doing algolia search: \(String(describing: error))")
                completion(.Error("Error finding your liked products, please try again"))
                return
            }
            
            guard let jsonData = jsonData else {
                print("deadBeef jsonData was either empty or poor connection")
                completion(.Error("Error finding your liked products, please try again"))
                return
            }
            
            guard let jsonInfo = jsonData["hits"] as? [[String: AnyObject]] else {
                print("deadBeef failed to parse products")
                completion(.Error("Error finding your liked products, please try again"))
                return
            }
            
            guard let nbOfPages = jsonData["nbPages"] as? UInt else {
                print("deadBeef failed error getting number of pages: \(String(describing: error))")
                completion(.Error("Error finding your liked products, please try again"))
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
                    print("deadBeef couldn't cast product in Saved Products")
                    continue
                }
            
                filteredProducts.append(castProduct)
            }
            
            DispatchQueue.main.async {
                completion(.Success(filteredProducts))
                weakSelf?.searchID += 1
                print("deadBeef XX searchID query: \(String(describing: weakSelf?.searchID))")
            }
            
        }
        
    }
    
    //MARK: deleteLiked(product)
    
    //called when a user is already logged in
    func deleteLiked(product: Product, uid: String, productArrayToDeleteFrom: [Product], completionHandler completion: @escaping successAndUpdateClosure) {
        
        print("----- deadBeef LPS product that will be deleted is \(String(describing: product.brand!)) \(String(describing: product.model!))")
        
        let productToDelete = product
        
        guard let objectID = productToDelete.objectID else {
            print("deadBeef LPS no productID to save (ProductSaver)")
            return completion(false, false)
        }
        
        let deleteProductRef = databaseRef.collection("Products").document(objectID)
        
        deleteProductRef.updateData([
            "LikedBy": FieldValue.arrayRemove([uid])
        ]) { err in
            if let err = err {
                print("deadBeef LPS Error updating document: \(err)")
                completion(false, false)
            } else {
                print("deadBeef LPS LikedBy document successfully deleted")
                print("deadBeef LPS_deleteLikedProduct thread: \(Thread.current)")
                
                let indexOfProductToDelete = productArrayToDeleteFrom.index(of: productToDelete)
                
                //Check if product that has been deleted has not yet been loaded into the mfTVC
                guard indexOfProductToDelete != nil else {
                    print("deadBeef LPS indexOfProductToDelete is out of range so exiting delete method")
                    //the likedBy has been updated and will be displayed correctly when the user scrolls to that position
                    completion(false, true)
                    return
                }
                
                print("deadBeef LPS indexOfProductToDelete: \(indexOfProductToDelete!)")
                let matchingProduct = productArrayToDeleteFrom[indexOfProductToDelete!]
                let indexOfUid = matchingProduct.likedBy?.index(of: uid)
                print("deadBeef LPS likedBy before delete: \(String(describing: matchingProduct.likedBy))")
                //We need to check if the uid exists in 
                if indexOfUid != nil {
                    matchingProduct.likedBy?.remove(at: indexOfUid!)
                }
                print("deadBeef LPS likedBy after delete: \(String(describing: matchingProduct.likedBy))")
                
                completion(true, false)
            }
        }
    }
    
    //MARK: like(Product)
    
    //called when a user is already logged in
    func like(product: Product, uid: String, productArrayToUpdate: [Product], completionHandler completion: @escaping successClosure) {
        
        print("----- deadBeef LPS_lP KK product that will be saved is \(String(describing: product.brand!)) \(String(describing: product.model!))")
        
        print("deadBeef KK like(product) count of productAraryToUpdate: \(productArrayToUpdate.count)")
        
        let productToSave = product
        
        guard let objectID = productToSave.objectID else {
            print("deadBeef LPS_lP KK no productID to save (ProductSaver)")
            completion(false)
            return
        }
        
        let savedProductRef = databaseRef.collection("Products").document(objectID)
        
        savedProductRef.updateData([
            "LikedBy": FieldValue.arrayUnion([uid])
        ]) { err in
            if let err = err {
                print("Error LPS_lP updating document: \(err)")
                completion(false)
                
            } else {
                print("deadBeef LPS_lP LikedBy document successfully updated")
                print("deadBeef LPS_likeProduct thread: \(Thread.current)")
                
                let indexOfProductToLike = productArrayToUpdate.index(of: productToSave)
                print("deadBeef LPS_lP KK indexOfProductToSave: \(indexOfProductToLike!)")
                let matchingProduct = productArrayToUpdate[indexOfProductToLike!]
                print("deadBeef LPS-lP KK matching product is: \(matchingProduct.brand)")
                print("deadBeef LPS_lP KK likedBy before save: \(String(describing: matchingProduct.likedBy))")
                print("deadBeef LPS_lP KK uid to append to likedBy: \(uid)")
                print("deadBeef likedBy type: \(type(of: matchingProduct.likedBy))")
                matchingProduct.likedBy?.append(uid)
                print("deadBeef LPS_lP KK likedBy after save: \(String(describing: matchingProduct.likedBy))")
                completion(true)
            }
        }
    }
    
    //MARK: likeProduct(atIndex:)
    
    //called when a user is not logged in yet
    func likeproduct(atIndex: Int, uid: String, productArrayToUpdate: [Product], completionHandler completion: @escaping successClosure) {
        
        print("----- deadBeef LPS_lPAI product that will be saved is \(String(describing: productArrayToUpdate[atIndex].brand)) \(String(describing: productArrayToUpdate[atIndex].model))")
        
        let productToSave = productArrayToUpdate[atIndex]
        
        guard let objectID = productToSave.objectID else {
            print("deadBeef LPS_lPAI no productID to save (ProductSaver)")
            completion(false)
            return
        }
        
        let savedProductRef = databaseRef.collection("Products").document(objectID)
        
        savedProductRef.updateData([
            "LikedBy": FieldValue.arrayUnion([uid])
        ]) { err in
            if let err = err {
                print("Error LPS_lPAI updating document: \(err)")
                completion(false)
                
            } else {
                print("deadBeef LPS_lPAI LikedBy document successfully updated")
                print("deadBeef LPS_likeProductAtIndex thread: \(Thread.current)")
                
                let indexOfProductToSave = productArrayToUpdate.index(of: productToSave)
                print("deadBeef LPS_lPAI indexOfProductToSave: \(indexOfProductToSave!)")
                let matchingProduct = productArrayToUpdate[indexOfProductToSave!]
                print("deadBeef LPS_lPAI likedBy before save: \(String(describing: matchingProduct.likedBy))")
                matchingProduct.likedBy?.append(uid)
                print("deadBeef LPS_lPAI likedBy after save: \(String(describing: matchingProduct.likedBy))")
                completion(true)
            }
        }
    }
    
    //MARK: deleteLikedProduct(atIndex:)
    
    //called when a user is not logged in yet
    func deleteLikedProduct(atIndex: Int, uid: String, productArrayToUpdate: [Product], completionHandler completion: @escaping successClosure) {
        
        print("----- deadBeef LPS_lPAI product that will be saved is \(String(describing: productArrayToUpdate[atIndex].brand)) \(String(describing: productArrayToUpdate[atIndex].model))")
        
        let productToDelete = productArrayToUpdate[atIndex]
        
        guard let objectID = productToDelete.objectID else {
            print("deadBeef LPS_lPAI no productID to save (ProductSaver)")
            completion(false)
            return
        }
        
        let deleteProductRef = databaseRef.collection("Products").document(objectID)
        
        deleteProductRef.updateData([
            "LikedBy": FieldValue.arrayRemove([uid])
        ]) { err in
            if let err = err {
                print("deadBeef LPS Error updating document: \(err)")
                completion(false)
            } else {
                print("deadBeef LPS LikedBy document successfully deleted")
                print("deadBeef LPS_unlikeProductAtIndex thread: \(Thread.current)")
                
                let indexOfProductToUpdate = productArrayToUpdate.index(of: productToDelete)
                
                //Check if product that has been deleted has not yet been loaded into the mfTVC
                guard indexOfProductToUpdate != nil else {
                    print("deadBeef LPS indexOfProductToDelete is out of range so exiting delete method")
                    //the likedBy has been updated and will be displayed correctly when the user scrolls to that position
                    completion(true)
                    return
                }
                
                print("deadBeef LPS indexOfProductToDelete: \(indexOfProductToUpdate!)")
                let matchingProduct = productArrayToUpdate[indexOfProductToUpdate!]
                let indexOfUid = matchingProduct.likedBy?.index(of: uid)
                print("deadBeef LPS likedBy before delete: \(String(describing: matchingProduct.likedBy))")
                //We need to check if the uid exists in
                if indexOfUid != nil {
                    print("deadBeef LPS uid is not nil, removing from phone array")
                    matchingProduct.likedBy?.remove(at: indexOfUid!)
                }
                print("deadBeef LPS likedBy after delete: \(String(describing: matchingProduct.likedBy))")
                
                completion(true)
            }
        }
    }
}
