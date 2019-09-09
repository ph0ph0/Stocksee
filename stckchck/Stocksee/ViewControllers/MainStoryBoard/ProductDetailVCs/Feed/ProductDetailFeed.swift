//
//  ProductDetailFeed.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class ProductDetailFeed: UIViewController, UIGestureRecognizerDelegate, IGListAdapterDelegate, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    weak var didDismissPDFDelegate: DidDismissPDFDelegate?
    weak var shouldShowProductDetailDelegate: ShouldShowPDFDelegate?
    
    //CollectionView should be scrolled this far to dismiss. Note that if this isn't large enough (approx 10) then the pDF can get stuck thinking that it should be dismissed
    var scrollViewDistanceToDismiss: CGFloat = 25
    
    //Tracks whether the cV should be dismissed if dragged down from top boundary
    var dragScrollViewToDismiss = true
    
    //Tracks whether the var above is ready to be set
    var dragScrollViewToDismissIsReady = false
    
    //Tracks initial cV offset
    var scrollViewInitialOffset: CGFloat = 0
    
    //Stores if the cV was loaded. Guards against overwriting scrollViewInitialOffset
    var scrollViewLoaded = false
    
    //Indicates if the pD is visible
    var productDetailIsShowing = false
    
    lazy var adapter: ListAdapter = {return ListAdapter(updater: ListAdapterUpdater(), viewController: self)}()
    
    var product = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The adapter should be set as the delegate to access the delegate functions
        adapter.scrollViewDelegate = self
        adapter.collectionViewDelegate = self
        
        print(print("deadBeef IGLK product count: \(product.count)"))
        print("deadBeef IGLK productSetTo: \(String(describing: product.first!.brand))")
        adapter.collectionView = collectionView
        adapter.dataSource = self
        //This should be set to false initially as the pDF will be at the bottom of the screen.
        collectionView.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        collectionView?.frame = view.bounds
    }
}

extension ProductDetailFeed: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return product
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DetailSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }
    
}

//MARK: ScrollView Delegate

extension ProductDetailFeed: UIScrollViewDelegate {
    
    //MARK: Scroll to Dismiss
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        //Don't need these, just here to satisfy the compiler
        
        print("deadBeef willDisplay index: \(index)")
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
        //Don't need these, just here to satisfy the compiler
        
        print("deadBeef didEndDisplaying index: \(index)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // store initial content offset of scroll view
        if !scrollViewLoaded {
            scrollViewLoaded = true
            scrollViewInitialOffset = scrollView.contentOffset.y
        }
        
        //Allow only bounce on the top, if we bounce on the bottom we see the mapview underneath, which we dont want.
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
        }
        
        if dragScrollViewToDismiss {
            // if scrolling up, cancel dismiss
            if scrollView.contentOffset.y - scrollViewInitialOffset > -scrollView.contentInset.top {
                dragScrollViewToDismiss = false
                dragScrollViewToDismissIsReady = false
            }
                // if scrolling down, dismiss view controller
            else if scrollView.contentOffset.y - scrollViewInitialOffset <= -scrollView.contentInset.top - scrollViewDistanceToDismiss {
                print("deadBeef IGLK would dismiss now")
                //Dismiss scrollview
                print("deadBeef dismissing pDF productDetailIsShowing: \(productDetailIsShowing), dragScrollViewToDismiss: \(dragScrollViewToDismiss), dragScrollViewToDismissIsReady: \(dragScrollViewToDismissIsReady), scrollViewLoaded: \(scrollViewLoaded)")
                productDetailIsShowing = false
                collectionView.isScrollEnabled = false
                didDismissPDFDelegate?.didDismissPDF()
            }
        }
        
    }
    
    // if scroll view released beyond top boundary, set dismiss ready
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            dragScrollViewToDismissIsReady = true
        }
    }
    
    // if scroll view drifts beyond top boundary, set dismiss ready
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            dragScrollViewToDismissIsReady = true
        }
    }
    
    // if scroll-to-top activated, set dismiss ready
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        dragScrollViewToDismissIsReady = true
    }
    
    // when tapping again on scroll view, set dismiss active
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if dragScrollViewToDismissIsReady {
            dragScrollViewToDismiss = true
        }
    }
    
    //Show the pDF if the user taps on the first cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("deadBeef indexPath of tapped cell is: \(indexPath)")
        
        //If the pDF is at the bottom of the screen and the user tapped on the DetailTitleCell, show the pDF
        if productDetailIsShowing == false && indexPath == [0,0] {
            let cell = collectionView.cellForItem(at: indexPath) as! DetailTitleCell
            productDetailIsShowing = true
            collectionView.isScrollEnabled = true
            print("deadBeef showing pDF productDetailIsShowing: \(productDetailIsShowing), dragScrollViewToDismiss: \(dragScrollViewToDismiss), dragScrollViewToDismissIsReady: \(dragScrollViewToDismissIsReady), scrollViewLoaded: \(scrollViewLoaded)")
            print("deadBeef IGLK tapped pDF, will show")
            shouldShowProductDetailDelegate?.showProductDetail()
        }
    }
    
    //Deals with the scroll view of the description cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("deadBeef cellreuseIdentifier: \(String(describing: cell.reuseIdentifier))")
        if cell.reuseIdentifier! == "Description" {
            let cell = cell as! DetailDescriptionCell
            
            cell.productDescriptionLabel.sizeToFit()
            cell.productDescriptionLabel.isScrollEnabled = true
            //cell.productDescriptionLabel.setContentOffset(CGPoint.zero, animated: false)
            cell.productDescriptionLabel.becomeFirstResponder()
            //cell.productDescriptionLabel.setContentOffset(CGPoint.zero, animated: false)
            cell.productDescriptionLabel.contentOffset.y = 0
            print("deadBeef set pDL as fR")
        }
    }
}
