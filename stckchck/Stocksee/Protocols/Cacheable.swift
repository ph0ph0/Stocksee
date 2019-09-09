//
//  Cacheable.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol cacheable {}

private let imageCache = NSCache<NSString, UIImage>()
private var previousDownloads = [Int]()

extension UIImageView: cacheable {}

extension cacheable where Self: UIImageView {
    
    typealias urlString = String
    
    typealias downloadCompletion = (UIImage, urlString) -> ()
    typealias successCompletion = (Bool) -> ()
    
    func loadImageFrom(product: Product, completionHandler completion: @escaping downloadCompletion) {
        
        let placeholderImage = UIImage(named: "CameraPlaceHolderImageGrey")
        //Note that imageURLs is a string not a [String]
        let imageURLs = product.imageURLs
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: imageURLs?[0] ?? "")) {
            
            DispatchQueue.main.async {
                completion(cachedImage, imageURLs![0])
                print("deadBeef loaded image from cache")
            }
            return
        }
        
        self.image = placeholderImage
        
        let mainImageRef = storage.reference(forURL: imageURLs![0])
        mainImageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            
            guard error == nil else {
                print("deadBeef failed to download image from storage: \(String(describing: error))")
                return
            }
            
            guard imageURLs == product.imageURLs else {
                print("deadBeef cancelling image assignment to iV as it's not required image")
                return
            }
            
            if let imageData = data {
                
                if let downloadedImage = UIImage(data: imageData) {
                    
                    imageCache.setObject(downloadedImage, forKey: NSString(string: imageURLs![0]))
                    
                    DispatchQueue.main.async {
                        
                        completion(downloadedImage, imageURLs![0])
                        print("deadBeef Image successfuly downloaded from network")
                        
                    }
                }
                
            } else {
                self.image = placeholderImage
                print("deadBeef failed to download image from network")
            }
        }
    }
    
    func loadImageFrom(url: String, completionHandler completion: @escaping successCompletion) {
        
        let placeholderImage = UIImage(named: "CameraPlaceHolderImageGrey")
        
        self.image = nil
        let imageURL = url
        
        if let cachedImage = imageCache.object(forKey: NSString(string: imageURL)) {
            DispatchQueue.main.async { [weak weakSelf = self] in
                weakSelf?.image = cachedImage
                completion(true)
                print("deadBeef image loaded from cache")
            }
            return
        }
        
        self.image = placeholderImage
        
        let mainImageRef = storage.reference(forURL: imageURL)
        mainImageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                print("\(String(describing: error))")
                return
            }
            
            if let imageData = data {
                
                if let downloadedImage = UIImage(data: imageData) {
                    
                    imageCache.setObject(downloadedImage, forKey: NSString(string: imageURL))
                    
                    DispatchQueue.main.async { [weak weakSelf = self] in
                        weakSelf?.image = downloadedImage
                        completion(true)
                        print("image downloaded from network")
                    }
                }
            } else {
                self.image = placeholderImage
            }
        }
    }
}









