//
//  FacetVC.swift
//  stckchck
//
//  Created by Pho on 22/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import UIKit
import AlgoliaSearch
import Dwifft

class FacetVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var diffCalculator: SingleSectionCollectionViewDiffCalculator<Facet>?
    var facetSearcher = FacetSearcher()
    var productMetaData = ProductMetaData()
    var activitySpinner = ActivitySpinner()
    var backButton: UIBarButtonItem?
    
    var facets = [Facet]() {
        didSet {
            facets.sort()
            self.diffCalculator?.items = facets
        }
    }
    weak var didSetFilterDelegate: DidSetFilterDelegate?
    
    enum Levels: String {
        case Category = "Meta.Category"
        case SubCategory = "Meta.SubCategory"
        case SubSubCategory = "Meta.SubSubCategory"
        case Sex = "Meta.Sex"
    }
    
    enum FacetSearchState {
        case idle
        case searching
    }
    
    var metaLevel = Levels.Category
    var current: FacetSearchState  = .idle {
        didSet {
            switch current {
            case .idle:
                collectionView.isUserInteractionEnabled = true
            case .searching:
                collectionView.isUserInteractionEnabled = false
            }
        }
    }
    
    var filterStringData = (filterString: "", endOfMetaLevels: false)
    var filterStringWasModified = false
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var facetLabel: UILabel!
    
    @IBOutlet var clearButtonOutlet: UIBarButtonItem!
    @IBAction func clearButton(_ sender: Any) {
        filterStringData.filterString = ""
        filterStringWasModified = true
        resetBackButtonTitle()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diffCalculator = SingleSectionCollectionViewDiffCalculator<Facet>(
            collectionView: collectionView,
            initialItems: facets
        )
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.57, green:0.73, blue:0.92, alpha:1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        facetLabel.text = ""
        facetLabel.alpha = 0
        facetLabel.layer.masksToBounds = true
        facetLabel.layer.cornerRadius = 10
        print("deadBeef fVC vDL filterString: \(filterStringData.filterString)")
        
        //Find topLevel facets
        showFacets(using: filterStringData, facet: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("deadBeef fVC vWA filterString: \(filterStringData.filterString)")
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        print("deadBeef fVC vWD filterString: \(filterStringData.filterString)")
        
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.tintColor = nil
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        
        if filterStringWasModified {
            didSetFilterDelegate!.didSetFilter(filterString: filterStringData.filterString)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("deadBeef nORIS: \(String(describing: facets.count))")
        return facets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FacetCell
        
        cell.didTapFacetDelegate = self
        
        let buttonName = facets[indexPath.row].facetRepresentation
        
        cell.facetButtonOutlet.setTitle(buttonName, for: .normal)
        cell.facetButtonOutlet.setBackgroundImage(UIImage(named: "FacetBackground"), for: .normal)
        cell.facetButtonOutlet.setTitleColor(UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.0), for: .normal)
        
        return cell
    }
}

//MARK: didTapFacet

extension FacetVC: DidTapFacetDelegate {
    
    //Handles the tap on the collection view cell
    func didTapFacet(at cell: FacetCell) {
        
        if facetLabel.alpha == 0 {
            UIView.animate(withDuration: 0.4) { [weak weakSelf = self] in
                weakSelf?.facetLabel.alpha = 1
            }
        }
        
        guard current == .idle else {
            print("deadBeef blocked addition to filterString as currently searching for facets")
            return
        }
        
        filterStringWasModified = true
        
        let cell = cell as FacetCell
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            print("deadBeef couldnt get index path of tapped facetCell")
            return
        }
        
        print("deadBeef index path of tapped cell is: \(indexPath)")
        
        let index = indexPath[1]
        let facet = facets[index]
        
        facetLabel.text = facet.facetRepresentation
        changeBarButtonTitle(facetName: facet.facetRepresentation)
        
        print("deadBeef facetName is: \(facet.facetName), facetRepresentation is: \(facet.facetRepresentation)")
        
        constructSearchString(from: facet)
    }
    
    //Handles constructing the searchString to feed into showFacets() and setting metaLevel
    func constructSearchString(from facet: Facet) {
        
        var filterStringData = self.filterStringData
        
        guard let facetName = facet.facetName, let facetRepresentation = facet.facetRepresentation else {
            print("deadBeef couldnt get facenName and facetRepresentation")
            return
        }
        
        print("deadBeef VB searchString out: \(filterStringData.filterString), facetName: \(facetName), mL: \(metaLevel)")
        
        //The only indication we have that the user has tapped on `Clothing` at this point is that the facetName is `Apparel`. We want to show them Men's/Women's clothing
        if facetName == "Apparel" {
            metaLevel = Levels(rawValue: productMetaData.Sex)!
            filterStringData.filterString = "\(productMetaData.Category):Apparel"
            showFacets(using: filterStringData, facet: nil)
            return
        }
        
        //Here we are updating the local searchString, and also setting the class property metaLevel.
        switch metaLevel {
        case .Category:
            filterStringData.filterString = "\(productMetaData.Category):\(facetName)"
            metaLevel = Levels(rawValue: productMetaData.SubCategory)!
            print("deadBeef XS didTap searchString: \(filterStringData.filterString)")
        case .Sex:
            filterStringData.filterString += " AND \(productMetaData.Sex):\(facetName)"
            metaLevel = Levels(rawValue: productMetaData.SubCategory)!
            print("deadBeef VB searchString in: \(filterStringData.filterString), facetName: \(facetName), mL: \(metaLevel)")
        case .SubCategory:
            filterStringData.filterString += " AND \(productMetaData.SubCategory):\(facetName)"
            metaLevel = Levels(rawValue: productMetaData.SubSubCategory)!
            print("deadBeef XS didTap searchString: \(filterStringData.filterString)")
        case .SubSubCategory:
            if !(filterStringData.filterString.contains(productMetaData.SubSubCategory)) {
                filterStringData.filterString += " AND \(productMetaData.SubSubCategory):\(facetName)"
            } else {
                print("deadBeef end of metaLevels")
            }
            print("deadBeef subSubSwitch filterString: \(filterStringData.filterString)")
            filterStringData.endOfMetaLevels = true
        }
        
        showFacets(using: filterStringData, facet: facet)
        
    }
    
    //Searches for the appropriate facets and adds them to [Facet]
    func showFacets(using filterStringData: (filterString: String, endOfMetaLevels: Bool), facet: Facet?) {
        print("deadBeef VB showFacets filterString: \(filterStringData.filterString), mL: \(metaLevel)")
        activitySpinner.spin(self.view)
        current = .searching
        facetSearcher.findFacets(in: metaLevel.rawValue, using: filterStringData, completionHandler: { [weak weakSelf = self] (facets) in
            var facets = facets
            var filterString = filterStringData.filterString
            weakSelf?.current = .idle
            weakSelf?.activitySpinner.spin(self.view, startAnimate: false)
            print("deadBeef fVC GG facetCount: \(facets.count)")
            if facets.isEmpty {
                print("deadBeef GG found no more facets")
                weakSelf?.filterStringData.filterString = filterString
                print("deadBeef fVC showFacets filterString (after append) facets.isEmpty: \(String(describing: weakSelf?.filterStringData.filterString))")
                guard let facet = facet else {
                    print("deadBeef no facet to move to top of fVC")
                    return
                }
                weakSelf?.facets = [facet]
                print("deadBeef fC facets empty count: \(facets.count)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                
            } else {
                print("deadBeef GG found facets ***!_!_!_!!_!_")
                for facet in facets {
                    print("deadBeef ****\(String(describing: facet.facetName))")
                }
                weakSelf?.filterStringData.filterString = filterString
                weakSelf?.facets = facets
                print("deadBeef facts count: \(weakSelf?.facets.count)")
                print("deadBeef fVC showFacets filterString (after append): \(String(describing: weakSelf?.filterStringData.filterString)), count: \(weakSelf?.facets.count)")
                print("deadBeef fC facets notEmpty count: \(facets.count)")
            }
        })
    }
    
    func changeBarButtonTitle(facetName: String?) {
        
        guard let facetName = facetName else {
            print("deadBeef 11 couldnt get facetName to display")
            return
        }
        print("deadBeef 11 changing barButtonTitle")
        
        let viewControllers = self.navigationController?.viewControllers ?? []
        
        guard let indexOfCurrentVC = viewControllers.index(of: self), (indexOfCurrentVC > viewControllers.startIndex) else {
            print("deadBeef 11 Couldnt get index of current VC")
            return
        }
        
        let indexOfPreviousVC = indexOfCurrentVC.advanced(by: -1)
        let previousViewController = viewControllers[indexOfPreviousVC]
        print("deadBeef 11 got index of currentVC: \(indexOfCurrentVC), previousVC: \(indexOfPreviousVC)")
        guard previousViewController is MainFeedTVC else {
            print("deadBeef 11 previousViewController was not MainFeedTVC")
            return
        }
        
        let backButtonTitle = "Apply: \(facetName)"
        
        let backButton = UIBarButtonItem()
        backButton.title = backButtonTitle
        previousViewController.navigationItem.backBarButtonItem = backButton

    }
    
    func resetBackButtonTitle(){
        print("deadBeef 11 changing title back")
        
        let viewControllers = self.navigationController?.viewControllers ?? []
        
        guard let indexOfCurrentVC = viewControllers.index(of: self), (indexOfCurrentVC > viewControllers.startIndex) else {
            print("deadBeef 11 Couldnt get index of current VC")
            return
        }
        
        let indexOfPreviousVC = indexOfCurrentVC.advanced(by: -1)
        let previousViewController = viewControllers[indexOfPreviousVC]
        print("deadBeef 11 got index of currentVC: \(indexOfCurrentVC), previousVC: \(indexOfPreviousVC)")
        guard previousViewController is MainFeedTVC else {
            print("deadBeef 11 previousViewController was not MainFeedTVC")
            return
        }
        
        let backButton = UIBarButtonItem()
        backButton.title = "ClearedAll"
        previousViewController.navigationItem.backBarButtonItem = backButton
    }
}
