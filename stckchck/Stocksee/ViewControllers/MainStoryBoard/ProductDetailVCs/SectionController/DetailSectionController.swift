//
//  DetailSectionController.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import IGListKit

class DetailSectionController: ListBindingSectionController<Product>, ListBindingSectionControllerDataSource {
    
    override init() {
        super.init()
        dataSource = self
    }
    
    var product: Product!
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        
        guard let product = object as? Product else {
            print("deadBeef IGLK detailSectionController failed to cast object as product")
            fatalError()
            
        }
        
        var sizeInfo: [String]?
        if product.size != nil {
            sizeInfo = product.size!
        } else {
            sizeInfo = nil
        }
        
        var results: [ListDiffable] = [
            DetailTitleVM(productTitle: "\(String(describing: product.brand!)) \(String(describing: product.model!))"),
            DetailImageVM(imageURLs: product.imageURLs!),
            DetailInfoVM(price: product.price!, shopName: product.shopName!, info: sizeInfo, distance: product.distance!)
            
        ]
        
        if product.desc != nil {
            let descVM = DetailDescriptionVM(description: product.desc!)
            results.append(descVM)
        }
        
        let notificationVM = DetailNotificationVM(notification: product.productCode)
        results.append(notificationVM)
        
        if product.instagramProfile != nil {
            let instagramProfile = product.instagramProfile!
            let instaVM = DetailInstaVM(buttonText: "Direct Message", instagramProfile: instagramProfile, productDetails: product)
            results.append(instaVM)
        }
        
        if product.shopPhoneNumber != nil {
            let phoneNumber = product.shopPhoneNumber!
            let callVM = DetailCallVM(shopPhoneNumber: phoneNumber, productDetails: product)
            results.append(callVM)
        }
        
        if product.openingTimes != nil {
            let openingTimes = product.openingTimes!
            let openingVM = DetailOpeningVM(openingTimes: openingTimes)
            results.append(openingVM)
        }
        
        
        return results
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        var identifier: String
        switch viewModel {
        case is DetailTitleVM:
            identifier = "Title"
        case is DetailImageVM:
            identifier = "Image"
        case is DetailInfoVM:
            identifier = "Info"
        case is DetailDescriptionVM:
            identifier = "Description"
        case is DetailInstaVM:
            identifier = "Insta"
        case is DetailCallVM:
            identifier = "Call"
        case is DetailOpeningVM:
            identifier = "Opening"
        case is DetailNotificationVM:
            identifier = "Notification"
        default:
            identifier = "Description"
        }
        
        guard let cell = collectionContext?.dequeueReusableCellFromStoryboard(withIdentifier: identifier, for: self, at: index) else {fatalError()}
        return cell as! UICollectionViewCell & ListBindable
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        
        guard let width = collectionContext?.containerSize.width else {
            print("deadBeef IGLK failed to get container width")
            fatalError()
            
        }
        
        var height: CGFloat
        switch viewModel {
        case is DetailTitleVM:
            height = 100
        case is DetailImageVM:
            height = 415
        case is DetailInfoVM:
            height = 139
        case is DetailDescriptionVM:
            height = 220
        case is DetailInstaVM:
            height = 54
        case is DetailCallVM:
            height = 66
        case is DetailOpeningVM:
            height = 200
        case is DetailNotificationVM:
            height = 50
        default:
            height = 50
        }
        
        return CGSize(width: width, height: height)
    }    
}
