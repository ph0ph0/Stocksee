//
//  ProfileViewController.swift
//  stckchck
//
//  Created by Pho on 29/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import UIKit
import FirebaseAuth
import Dwifft
import Reachability
import Crashlytics
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    //MARK: Properties
    
    var uid: String?
    var diffCalculator: SingleSectionTableViewDiffCalculator<Product>?
    var likedProductService = LikedProductService()
    var userLocation: (lat: Double, lng: Double)?
    let loadingAnimation = LoadingAnimation()
    
    var wasOffline = false {
        willSet {
            if newValue == false {
                //no need to removeAll() before calling displayProducts() as the diffCalculator works out what should be shown
                displayProducts()
            }
        }
    }
    
    var productArray = [Product]() {
        didSet {
            DispatchQueue.main.async { [weak weakSelf = self] in
                weakSelf?.diffCalculator?.rows = (weakSelf?.productArray)!
                let contentOffset = weakSelf?.tableView.contentOffset
                weakSelf?.tableView.setContentOffset(contentOffset!, animated: false)
                weakSelf?.loadingAnimation.stop()
            }
            
        }
    }
    
    var productsPassedFromMFVC = [Product]()
    var productsRemoved = [Product]()
    var logoutListener: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkStatusIndicator: NetworkStatusIndicator!
    
    
    @IBAction func signOutButton(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        //FirebaseAnalytics Data Capture Point
        
        do {
            
            //Send Analytics - This should be before erasing uIM, as we need to know who logged out
            AnalyticsManager.sharedInstance.sendLogoutEventToAnalytics(userLocation: userLocation)
            
            //remove all the settings in the UserInfoManager
            
            
            try firebaseAuth.signOut()
            let loginManager = FBSDKLoginManager()
            
            logoutListener = firebaseAuth.addStateDidChangeListener { (auth, user) in
                if user == nil {
                    print("deadBeef pVC signout successful")
                    if FBSDKAccessToken.current() != nil {
                        loginManager.logOut()
                    }
                    UserInfoManager.sharedInstance.resetUserInfo()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("deadbeef pVC attaching logoutListener")
                }
            }
            
            
            
        } catch let signoutError as NSError {
            
            print("deadBeef pVC Error signing out: %@", signoutError)
            
        }
        
    }
    
    override func viewDidLoad() {
        
        //MARK: vDL standard setup
        
        uid = Auth.auth().currentUser?.uid
        print("deadBeef pVC pVC uid: \(String(describing: uid))")
        
        //MARK: vDL tableView autoupdate, insert and remove
        diffCalculator = SingleSectionTableViewDiffCalculator<Product>(
            tableView: tableView,
            initialRows: productArray
        )
        diffCalculator?.insertionAnimation = .fade
        diffCalculator?.deletionAnimation = .left
        
        //MARK: vDL TableViewSetup
        tableView.delegate = self
        self.title = "Saved Products"
        let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0.30, green: 0.30, blue: 0.30, alpha:1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        //MARK: LikedProductService
        displayProducts()
        
        //MARK: Set Nav Con Delegate
        //navigationController?.delegate = self
        
    }
    
    //MARK: vWA/vWD
    
    override func viewWillAppear(_ animated: Bool) {
        print("deadBeef pVC_vWA currentUser in UserManager: \(UserInfoManager.sharedInstance.getUID()), in Firebase: \(String(describing: Auth.auth().currentUser?.uid))")
        ReachabilityManager.sharedInstance.addListener(listener: self)
        print("deadBeef pVC_vwA ReachabilityStatus: \(ReachabilityManager.sharedInstance.reachabilityStatus)")
        networkStatusIndicator.removeNetworkStatusIndicator()
        if ReachabilityManager.sharedInstance.reachabilityStatus == .none {
            networkStatusIndicator.showNoNetworkIndicator()
            wasOffline = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ReachabilityManager.sharedInstance.removeListener(listener: self)
        loadingAnimation.stop()
        if logoutListener != nil {
            Auth.auth().removeStateDidChangeListener(logoutListener!)
        }
    }
    
}

//MARK: TableView Delegate and DataSource

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.diffCalculator?.rows.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedProductCell", for: indexPath)
        
        if let cell = cell as? SavedProductCell {
            cell.product = productArray[indexPath.row]
            cell.didPressDeleteButtonDelegate = self
        }
        return cell
    }
}

//MARK: Segue Prep

extension ProfileViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToDetailSegue" {
            let destination = segue.destination as? ProductDetailVC
            let indexPath = self.tableView.indexPathForSelectedRow!
            let row = indexPath.row
            let productToShow = productArray[row]
            destination?.product = productToShow
        }
    }
    
}

//MARK: DidPressDeleteButtonDelegate
extension ProfileViewController: DidPressDeleteButtonDelegate {
    func deleteProductViaDeleteButton(cell: SavedProductCell) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let indexPath = tableView.indexPath(for: cell)
        let index = indexPath![1]
        let productToDelete = productArray[index]
        
        likedProductService.deleteLiked(product: productToDelete, uid: uid!, productArrayToDeleteFrom: productsPassedFromMFVC) { [weak weakSelf = self] (success, reload) in
            if success && !reload {
                //This represents when the product has been updated in Firestore and in the mfTVC.
                DispatchQueue.main.async {
                    weakSelf?.productArray.remove(at: index)
                    cell.deleteLikedButtonOutlet.hideLoading()
                    //If we don't reset the image, then when the cell is reused, the DeleteCross is absent
                    cell.deleteLikedButtonOutlet.imageView?.image = UIImage(named: "DeleteCross")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else if !success && !reload {
                //Try Again somehow, this represents when the product cannot be updated in Firestore and so the table should not be reloaded.
                print("deadBeef pVC failed to delete product")
                cell.deleteLikedButtonOutlet.hideLoading()
                cell.deleteLikedButtonOutlet.imageView?.image = UIImage(named: "DeleteCross")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else if !success && reload {
                //This represents when the likedBy attribute in Firestore has been updated, but the product hasn't yet been loaded into the mfTVC and so attempting to update the mfTVC array would cause a crash as the index would be out of range.
                weakSelf?.productArray.remove(at: index)
                cell.deleteLikedButtonOutlet.hideLoading()
                cell.deleteLikedButtonOutlet.imageView?.image = UIImage(named: "DeleteCross")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

//MARK: DisplayProducts

extension ProfileViewController {
    func displayProducts() {
        view.addSubview(loadingAnimation)
        loadingAnimation.display()
        
        likedProductService.findLikedProducts(around: (lat: (userLocation?.lat)!, lng: (userLocation?.lng)!)) { [weak weakSelf = self] (returnedProducts) in
            
            switch returnedProducts {
            case .Success(let products):
                weakSelf?.productArray = products
                //FirebaseAnalytics Data capture point
                print("deadBeef pVC received data from productSearcher, product count: \(String(describing: weakSelf?.productArray.count))")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .Error(let error):
                //Search bar setting
                print("deadBeef pVC error searching Firestore: \(error)")
                weakSelf?.alertMessage("Sorry", message: error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

//MARK: NetworkStatus

extension ProfileViewController: NetworkStatusListener {
    
    //If reachability screws up it may be because of the queue's
    func networkStatusDidChange(status: Reachability.Connection) {
        print("deadBeef mfTVC_nSDC listener: \(status)")
        
        DispatchQueue.main.async { [weak weakSelf = self] in
            switch status {
            case .none:
                weakSelf?.networkStatusIndicator.showNoNetworkIndicator()
                weakSelf?.wasOffline = true
            case .cellular:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
                //can force unwrap as in order to be a listner, self has to be added to Reachability.Listeners
                if (weakSelf?.wasOffline)! {
                    weakSelf?.wasOffline = false
                }
            case .wifi:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
                if (weakSelf?.wasOffline)! {
                    weakSelf?.wasOffline = false
                }
            }
        }
    }
    
}












