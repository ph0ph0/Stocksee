//
//  ViewController.swift
//  stckchck
//
//  Created by Pho on 21/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import UIKit
import CoreLocation
import Dwifft
import FirebaseAuth
import Lottie
import Reachability
import Crashlytics
import Firebase
import FBSDKLoginKit

class MainFeedTVC: UIViewController {
    
    fileprivate enum State {
        case filtering
        case showingAll
        case loading
        case findingLocation
    }
    
    fileprivate var currentState: State = .loading {
        willSet {
            print("deadBeef mfTVC setting state to: \(newValue)")
            if newValue == .loading {
                searchFooter.setFindingProducts()
                loadingAnimation.display()
                view.addSubview(loadingAnimation)
                productArray.removeAll()
            } else if newValue == .filtering || newValue == .showingAll {
                loadingAnimation.stop()
                searchFooter.setNotFiltering()
            } else if newValue == .findingLocation {
                networkStatusIndicator.showFindingLocation()
            }
        }
        didSet {
            if oldValue == .findingLocation {
                networkStatusIndicator.showFoundLocation()
            }
        }
    }
    
    var productArray = [Product]() {
        didSet {
            DispatchQueue.main.async { [weak weakSelf = self] in
                //the product array is initiated as an empty array, so we check if it has been populated yet
                if (weakSelf?.firstLoadDone)! {
                    //profile button is disabled til productArray is set, as otherwise when segue to pVC, app crashes as user location hasn't been set yet. We know that it will be set by the time productArray is, as products cannot be retrieved unless we have the location.
                    weakSelf?.profileButtonOutlet.isEnabled = true
                }
                weakSelf?.tableView.reloadData()
                //weakSelf?.diffCalculator?.rows = (weakSelf?.productArray)!
                let contentOffset = weakSelf?.tableView.contentOffset
                guard contentOffset != nil else {
                    print("deadBeef mfTVC setting productArray and contentOffset = nil")
                    return
                }
                weakSelf?.tableView.setContentOffset(contentOffset!, animated: false)
            }
        }
    }
    
    //var diffCalculator: SingleSectionTableViewDiffCalculator<Product>?
    let searchController = UISearchController(searchResultsController: nil)
    let productSearcher = ProductSearcher()
    var locationManager: CLLocationManager?
    var userLocation: (lat: Double, lng: Double)? {
        willSet {
            let nV = newValue
            print("deadBeef new location is \(String(describing: nV))")
            if !firstLoadDone {
                if uid == nil {
                   
                    performSegue(withIdentifier: "WelcomeSegue", sender: self)
                    
                }
            }
        }
    }
    
    var firstLoadDone = false
    var geoRadius: CGFloat = 2
    var geoRadiusLabel = GeoRadiusLabel()
    
    var uid: String? {
        willSet {
            if newValue == nil && firstLoadDone {
                
                performSegue(withIdentifier: "WelcomeSegue", sender: self)
            }
        }
    }
    
    let likedProductService = LikedProductService()
    var locationAttempts = 0
    var loadingAnimation = LoadingAnimation()
    var authHandle: AuthStateDidChangeListenerHandle?
    var logoutListener: AuthStateDidChangeListenerHandle?
    
    var currentBackButtonTitle: String?
    
    //Used to animate and show the refreshButton.
    var readyToRefresh = false {
        willSet {
            if newValue == true {
                refreshButtonOutlet.customView!.transform = CGAffineTransform(scaleX: 0, y: 0)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0,
                                   delay: 0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 5,
                                   options: .curveLinear,
                                   animations: { [weak weakSelf = self] in
                                    weakSelf?.refreshButtonOutlet.customView?.alpha = 1
                                    weakSelf?.refreshButtonOutlet.customView!.transform = CGAffineTransform.identity
                        },
                                   completion: nil)
                }
            } else if newValue == false {
                refreshButtonOutlet.customView!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 5/5))
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0,
                                   delay: 0,
                                   options: .curveEaseInOut,
                                   animations: { [weak weakSelf = self] in
                                    weakSelf?.refreshButtonOutlet.customView!.transform = CGAffineTransform.identity
                    }) { (success) in
                        UIView.animate(withDuration: 0.3,
                                       animations: { [weak weakSelf = self] in
                                        weakSelf?.refreshButtonOutlet.customView?.alpha = 0
                        })
                    }
                }
            }
        }
    }
    
    var networkIsAvailable = false {
        willSet {
            if newValue == true {
                userLocation = nil
                print("deadBeef mfTVC_nIA removed userLocation")
                DispatchQueue.main.async { [weak weakSelf = self] in
                    weakSelf?.locationManager = CLLocationManager()
                    weakSelf?.locationManager!.requestAlwaysAuthorization()
                    weakSelf?.locationManager!.requestWhenInUseAuthorization()
                    if CLLocationManager.locationServicesEnabled() {
                        weakSelf?.locationManager!.delegate = self
                        weakSelf?.locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        print("deadBeef mfTVC_nIA getting location")
                        weakSelf?.locationManager!.distanceFilter = 75
                        weakSelf?.locationManager!.startUpdatingLocation()
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var filterButtonOutlet: FilterButton!
    
    @IBAction func filterButton(_ sender: Any) {
        guard let filterButton = filterButtonOutlet else {
            print("deadBeef failed to get filter button")
            return
        }
        
        let current = filterButton.getCurrentState()
        
        switch current {
        case .facetsApplied:
            //If orange, clear the filters, search, reset back button and change to blue
            print("deadBeef filterButton removing filters and searching")
            let filterString = ""
            productSearcher.query.filters = filterString
            searchController.searchBar.text = nil
            displayProducts("")
            currentBackButtonTitle = "ClearedAll"
            filterButtonOutlet.changeState(accordingTo: filterString)
        case .noFacets:
            print("deadBeef filterButton no filters, segueing to facetVC")
            performSegue(withIdentifier: "FacetVCSegue", sender: self)
        }
        
    }
    
    
    @IBOutlet weak var radiusIndicator: UIBarButtonItem!
    @IBOutlet weak var profileButtonOutlet: UIBarButtonItem!
    @IBOutlet var refreshButtonOutlet: UIBarButtonItem! {
        didSet {
            let icon = UIImage(named: "RefreshButton")
            let iconSize = CGRect(origin: CGPoint.zero, size: icon!.size)
            let refreshButton = UIButton(frame: iconSize)
            refreshButton.setBackgroundImage(icon, for: .normal)
            refreshButtonOutlet.customView = refreshButton
            refreshButton.addTarget(self, action: #selector(tappedRefreshButton), for: .touchUpInside)
        }
    }
    
    @objc func tappedRefreshButton(){
        print("deadBeef pressed refresh")
        if searchBarIsEmpty() {
            displayProducts("")
            print("refreshing all products")
            readyToRefresh = false
        } else if !searchBarIsEmpty() {
            let searchBar = searchController.searchBar
            displayProducts(searchBar.text!)
            readyToRefresh = false
        }
    }
    
    @IBAction func profileBarButton(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "MainFeedToProfileSegue", sender: self)

    }
    
    @IBOutlet weak var searchFooter: SearchFooter!
    // allProductsLoaded is used to control the findingProducts... searchFooter when more products are being loaded into the table. This variable is set in the willDisplayCell and displayProducts().
    var allProductsLoaded = false
    @IBOutlet weak var networkStatusIndicator: NetworkStatusIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Authentication Details
        
        uid = Auth.auth().currentUser?.uid
        
        print("deadBeef mfTVC currentUser (mfTVC): \(String(describing: uid))")
        
        //MARK: tableViewSetup
        productArray.removeAll()
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.scrollsToTop = true
        //This prevents the top cell from being obscured by the search bar when we segue back to this view.
        self.extendedLayoutIncludesOpaqueBars = true
        
        //MARK: NavBar Setup
        navigationController?.navigationBar.barTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        //set background colour to white so when we segue away we dont see black as the seach bar retracts
        navigationController?.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //MARK: vDL Location Services Setup
        profileButtonOutlet.isEnabled = false
        radiusIndicator.title = "\(geoRadius) km"
        radiusIndicator.isEnabled = false
        //radiusIndicator.setTitlePositionAdjustment(UIOffset(horizontal: -7, vertical: 0), for: UIBarMetrics.default)
        radiusIndicator.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 4)!
            ], for: .normal)
        
        if !firstLoadDone {
            refreshButtonOutlet.customView?.alpha = 0
        }
        
        //MARK: gR Setup
        let viewPinched = UIPinchGestureRecognizer(target: self, action: #selector(changeGeoRadiusWith(pinch:)))
        view.addGestureRecognizer(viewPinched)
        
        //MARK: tableView autoupdate, insert and remove
//        diffCalculator = SingleSectionTableViewDiffCalculator<Product>(
//            tableView: tableView,
//            initialRows: productArray
//        )
//        diffCalculator?.insertionAnimation = .fade
//        diffCalculator?.deletionAnimation = .fade
        
        //MARK: Search Controller setup
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        searchController.definesPresentationContext = true
        
        //For segue to WelcomeVC as this VC is presented Modally
        definesPresentationContext = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //This ensures that the searchBar is visible on first load. It is also necessary to have = false in the vWA. See below
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // This sets the barButtonTitle of the back button
        getAndResetCurrentBackBarButtonTitle()
        
        //This ensures that the searchBar is visible on first load. It is also necessary to have = true in the vDA. See above
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set uid class property and in UserInfoManager
        authHandle = Auth.auth().addStateDidChangeListener({ [weak weakSelf = self] (auth, user) in
            if user != nil {
                //user is force unwrapped as we dont want the user waltzing around our app without the uid set.
                weakSelf?.uid = user!.uid
                //Create a local userID variable so that if self no longer exists, we can still access the uid
                let userID = user!.uid
                print("deadBeef Thread adding authHandle on: \(Thread.current), main?: \(Thread.isMainThread)")
                Crashlytics.sharedInstance().setUserEmail(Auth.auth().currentUser?.email)
                Crashlytics.sharedInstance().setUserIdentifier(userID)
                if !UserInfoManager.sharedInstance.propertiesSet {
                    DispatchQueue.global().async {
                        print("deadBeef Thread UserInfoManager (vWA) propertiesSet on: \(Thread.current), main?: \(Thread.isMainThread)")
                        let userInfoRef = databaseRef.collection("UserInfo").document(userID)
                        userInfoRef.getDocument(completion: { [weak weakSelf = self] (snap, error) in
                            if error == nil { //If a user is created without a birthYear or a sex, then we need to force log them out and get them to sign in again, as otherwise the app will crash.
                                
                                let userData = snap?.data() as [String: Any]?
                                guard let birthYear = userData?[UserInfoProperties.Parameters.BirthYear.rawValue] as? Int else {
                                    AnalyticsManager.sharedInstance.sendIncompleteUserInfoError(uid: weakSelf?.uid)
                                    print("deadBeef User currently signed in with incomplete details (no birthyear)")
                                    weakSelf?.alertMessage("There has been an error finding your profile... If this persists, please create a new profile", message: "Please log in again")
                                    let firebaseAuth = Auth.auth()
                                    do {
                                        try firebaseAuth.signOut()
                                        let loginManager = FBSDKLoginManager()
                                        weakSelf?.logoutListener = firebaseAuth.addStateDidChangeListener { (auth, user) in
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
                                    return
                                }
                                print("deadBeef mfTVC_vWA BirthYear: \( birthYear)")
                                guard let userSex = userData?[UserInfoProperties.Parameters.Sex.rawValue] as? String else {
                                    AnalyticsManager.sharedInstance.sendIncompleteUserInfoError(uid: weakSelf?.uid)
                                    print("deadBeef user currently signed in with incomplete details (no sex)")
                                    weakSelf?.alertMessage("There has been an error finding your profile...", message: "Please log in again")
                                    let firebaseAuth = Auth.auth()
                                    do {
                                        try firebaseAuth.signOut()
                                        let loginManager = FBSDKLoginManager()
                                        weakSelf?.logoutListener = firebaseAuth.addStateDidChangeListener { (auth, user) in
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
                                    return
                                }
                                
                                print("deadBeef mfTVC_vWA uid: \(String(describing: userID)), bY: \(birthYear), userSex: \(userSex)")
                                UserInfoManager.sharedInstance.setUserInfo(userBirthYear: birthYear, userSex: userSex, uid: userID)
                            }
                        })
                    }
                }
            } else {
                //If uid from Auth is nil then we just set it to the default nil values.
                let birthYear = UserInfoManager.sharedInstance.getBirthYear()
                let sex = UserInfoManager.sharedInstance.getUserSex()
                weakSelf?.uid = UserInfoManager.sharedInstance.getUID()
                print("deadBeef mfTVC_vWA uid is nil from Auth, in UserInfoManager uid: \(String(describing: weakSelf?.uid)), sex: \(sex), bY: \(birthYear) ")
            }
        })
        
        searchController.definesPresentationContext = true
        ReachabilityManager.sharedInstance.addListener(listener: self)
        //firstLoadDone = false
        print("deadBeef mfTVC uid: \(String(describing: uid))")
        print("deadBeef mfTVC currentState: \(currentState)")
        //reload the data so that if any products were deleted from pVC they are updated here
        tableView.reloadData()
        print("deadBeef mfTVC_vwA ReachabilityStatus: \(ReachabilityManager.sharedInstance.reachabilityStatus)")
        networkStatusIndicator.removeNetworkStatusIndicator()
        if ReachabilityManager.sharedInstance.reachabilityStatus == .none {
            networkStatusIndicator.showNoNetworkIndicator()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ReachabilityManager.sharedInstance.removeListener(listener: self)
        loadingAnimation.stop()
        if authHandle != nil {
            Auth.auth().removeStateDidChangeListener(authHandle!)
            print("deadBeef mfTVC_vWD removed authHandle")
        }
        if logoutListener != nil {
            Auth.auth().removeStateDidChangeListener(logoutListener!)
        }
    }
    
}

// MARK: TableViewDataSource and Delegate

extension MainFeedTVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("deadBeef mfTVC productArray count nORIS: \(productArray.count)")
        
        print("deadBeef mfTVC isFiltering: \(isFiltering())")
        
        if isFiltering() && currentState != .loading {
            searchFooter.setIsFilteringToShow(filteredItemCount: productArray.count)
        }
        
        return productArray.count
        //return (self.diffCalculator?.rows.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath)
        
        let product: Product
        
        product = productArray[indexPath.row]
        
        if let cell = cell as? MainFeedProductCell {
            //cell.imageView?.image = nil
            cell.didPressLikeButtonDelegate = self
            cell.product = product
            
        }
        
        return cell        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

//MARK: Tableview Load more cells

extension MainFeedTVC {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 5) >= productArray.count {
            
            if allProductsLoaded == false {
                searchFooter.setFindingProducts()
            }
            
            print("deadBeef mfTVC yy loading from cell \(indexPath.row)")
            productSearcher.loadMore(completionHandler: { [weak weakSelf = self] (products) in
                
                switch products {
                case .Success(let products):
                    print("deadBeef mfTVC new productArray count: \(String(describing: weakSelf?.productArray.count))")
                    weakSelf?.productArray.append(contentsOf: products)
                    weakSelf?.searchFooter.setNotFiltering()
                    weakSelf?.allProductsLoaded = false
                    //TableViewFooter
                case .Error(let error):
                    print("deadBeef mfTVC error adding more products: \(error)")
                    weakSelf?.searchFooter.setNotFiltering()
                    weakSelf?.allProductsLoaded = true
                    //TableViewFooter
                }
            })
        }
    }
}

// MARK: Segue Prep

extension MainFeedTVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "FacetVCSegue" {
            getAndResetCurrentBackBarButtonTitle()
        }
        
        if segue.identifier == "DetailSegue" {
            let destination = segue.destination as? ProductDetailVC
            let indexPath = self.tableView.indexPathForSelectedRow!
            let row = indexPath.row
            let productToShow = productArray[row]
            destination?.product = productToShow
            destination?.currentUserLocation = userLocation
            print("deadbeef current uid: \(uid)")
        } else if segue.identifier == "WelcomeSegue" {
            let destination = segue.destination as? WelcomeViewController
            destination?.userLocation = userLocation
        } else if segue.identifier == "MainFeedToProfileSegue" {
            let destination = segue.destination as? ProfileViewController
            destination?.userLocation = userLocation
            destination?.productsPassedFromMFVC = productArray
        } else if segue.identifier == "FacetVCSegue" {
            let destination = segue.destination as? FacetVC
            destination?.didSetFilterDelegate = self
            
            setBackButtonText()
        }
    }
    
    @IBAction func unwindToMainFeed(segue: UIStoryboardSegue) {}
}

//MARK: Location Services

extension MainFeedTVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("deadBeef Thread locationManager updatingLocation on: \(Thread.current), main?: \(Thread.isMainThread)")
        
        if !firstLoadDone {
            currentState = .findingLocation
        }
        
        guard networkIsAvailable else {
            print("deadBeef mfTVC_locationManager network isn't available yet")
            return
        }
    
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if let location = locations.first {
            userLocation = (lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            print("deadBeef mfTVC found user location: \(location.coordinate.latitude, location.coordinate.longitude)")
            if !firstLoadDone {
                //State Handling
                print("deadBeef mfTVC_lM_didUpdateLocations ReachabilityManager.reachabilityStatus: \(ReachabilityManager.sharedInstance.reachabilityStatus)")
                displayProducts("")
                firstLoadDone = true
                locationAttempts = 0
            } else if firstLoadDone {
                print("deadBeef readyToRefresh!")
                //If first load is done, then the user has moved 75 metres and hence the feed needs to be updated as it is probably not showing the correct distances
                readyToRefresh = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("deadBeef mfTVC failed to get location!: \(error.localizedDescription)")
        
        if locationAttempts < 3 {
            locationAttempts += 1
            
            alertMessage("Failed to get location!", message: "Please ensure that stckchck can access your location by going to Settings > stckchck > Location: Always. Now trying again, try \(locationAttempts) of 4")
            
            guard let unwrappedLocationManager = locationManager else {
                print("deadBeef locationManager is not initialised")
                return
            }
            
            unwrappedLocationManager.stopUpdatingLocation()
            unwrappedLocationManager.startUpdatingLocation()
            
        } else {
            locationAttempts = 0
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            alertMessage("Couldn't get your location", message: "Please ensure that stckchck can access your location by going to Settings > stckchck > Location: Always and then restart the app. You may have to move to a location with better signal")
        }
        
    }
}

// MARK: DisplayProducts

extension MainFeedTVC {
    
    func displayProducts(_ searchText: String) {
        
        currentState = .loading
        allProductsLoaded = false
        
        let radius = UInt(geoRadius * 1000)
        print("deadBeef mfTVC radius: \(radius)")
        
        guard let userLocation = userLocation else {
            print("deadBeef mfTVC failed to get userLocation in search")
            return
        }
        
        DispatchQueue.global().async { [weak weakSelf = self] in
            weakSelf?.productSearcher.searchAlgolia(around: userLocation, with: searchText, within: radius) { [weak weakSelf = self] (returnedProducts) in
                
                print("deadBeef mfTVC searching Algolia on main queue?: \(Thread.isMainThread)")
                
                switch returnedProducts {
                case .Success(let products):
                    DispatchQueue.main.async {
                        if searchText == "" {
                            weakSelf?.currentState = .showingAll
                        } else if searchText != "" {
                            weakSelf?.currentState = .filtering
                            
                            //Set Analytics
                            let filterString = weakSelf?.productSearcher.query.filters
                            AnalyticsManager.sharedInstance.sendSearchEventToAnalytics(searchText: searchText, products: products, filterString: filterString, geoRadius: (weakSelf?.geoRadius)!, userLocation: weakSelf?.userLocation)
                            
                        }
                        
                        print("deadBeef mfTVC updating productArray on main queue?: \(Thread.isMainThread)")
                        weakSelf?.productArray = products
                        print("deadBeef mfTVC received data from productSearcher, productArray count: \(String(describing: weakSelf?.productArray.count))")
                        print("deadBeef mfTVC received data from productSearcher.numberOfProducts count: \(String(describing: weakSelf?.productArray.count))")
                        if products.count == 0 {
                            weakSelf?.noResultsFoundAlert()
                            weakSelf?.searchFooter.setIsFilteringToShow(filteredItemCount: 0)
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    }
                case .Error(let error):
                    DispatchQueue.main.async {
                        if searchText == "" {
                            weakSelf?.currentState = .showingAll
                        } else if searchText != "" {
                            weakSelf?.currentState = .filtering
                        }
                        print("deadBeef mfTVC updating productArray on main queue?: \(Thread.isMainThread)")
                        weakSelf?.searchController.searchBar.text = ""
                        print("deadBeef mfTVC error searching Firestore: \(error)")
                        weakSelf?.alertMessage("Error", message: error)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
    }
}

// MARK: Pinch Gesture

extension MainFeedTVC {
    
    @objc func changeGeoRadiusWith(pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            print("deadBeef mfTVC pinch began")
            view.addSubview(geoRadiusLabel)
            geoRadiusLabel.displayGeoRadiusLabel()
        case .changed:
            
            if pinch.scale > 1.05 {
                geoRadius = min(50, (geoRadius + 0.5))
                geoRadiusLabel.text = "\(geoRadius) km"
                print("deadBeef mfTVC geoRadius: \(geoRadius)")
                pinch.scale = 1
                radiusIndicator.title = "\(geoRadius) km"
            } else if pinch.scale < 0.95 {
                geoRadius = max(0.5, (geoRadius - 0.5))
                geoRadiusLabel.text = "\(geoRadius) km"
                print("deadBeef mfTVC geoRadius: \(geoRadius)")
                pinch.scale = 1
                radiusIndicator.title = "\(geoRadius) km"
            }
            
        case .failed:
            print("deadBeef mfTVC pinch fail")
            geoRadiusLabel.removeGeoRadiusLabel()
        case .cancelled:
            print("deadBeef mfTVC pinch cancelled")
            geoRadiusLabel.removeGeoRadiusLabel()
        case .ended:
            print("deadBeef mfTVC pinch ended, new geoRadius: \(geoRadius)")
            geoRadiusLabel.removeGeoRadiusLabel()
            geoRadiusDidChange()
            AnalyticsManager.sharedInstance.sendGeoRadiusDidChangeEventToAnalytics(geoRadius: geoRadius, userLocation: userLocation)
        default:
            break
        }
    }
}

extension MainFeedTVC: GeoRadiusDidChangeDelegate {
    
    func geoRadiusDidChange() {
        switch currentState {
        case .showingAll:
            displayProducts("")
            print("deadBeef mfTVC geoRadius changed and showing all")
            if productArray.count != 0 {
                tableView.scrollToRow(at: [0,0], at: .top, animated: false)
            }
        case .filtering:
            displayProducts(searchController.searchBar.text!)
            print("deadBeef mfTVC geoRadius changed and filtered")
            if productArray.count != 0 {
                tableView.scrollToRow(at: [0,0], at: .top, animated: false)
            }
        case .loading:
            print("deadBeef mfTVC_gRDC loading when trying to change geoRadius")
        case .findingLocation:
            print("deadBeef mfTVC_gRDC finding location")
        }
        
    }
}

//MARK: Search Controller Services

extension MainFeedTVC: UISearchResultsUpdating {
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //Removed search per letter and opted for search on full term.
    }
    
    
}

//MARK: Search bar delegate

extension MainFeedTVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("deadBeef mfTVC search button tapped")
        
        let searchBar = searchController.searchBar
        
        switch currentState {
        case .showingAll:
                if searchBarIsEmpty() {
                    displayProducts("")
                } else if !searchBarIsEmpty() {
                    displayProducts(searchBar.text!)
            }
        case .filtering:
            if searchBarIsEmpty() {
                displayProducts("")
            } else if !searchBarIsEmpty() {
                displayProducts(searchBar.text!)
            }
        case .loading:
            print("deadBeef mfTVC_sBSBC trying to search when already searching")
        case .findingLocation:
            print("deadBeef mfTVC_sBSBC finding location")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("deadBeef mfTVC cancel tapped")
        switch currentState {
        case .showingAll:
            print("deadBeef mfTVC cancel tapped when showingAll")
        case .filtering:
            displayProducts("")
        case .loading:
            print("deadBeef mfTVC_sBCBC tapped cancel when loading")
        case .findingLocation:
            print("deadBeef mfTVC_sBCBC finding location")
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("deadBeef mfTVC_searchBarDelegate SearchBar tapped")
        
    }
    
}


//MARK: DidPressLikeButtonDelegate

extension MainFeedTVC: DidPressLikeButtonDelegate {
    
    func didPressLikeButton(at cell: UITableViewCell) {
        let cell = cell as! MainFeedProductCell
        
        guard uid != nil else {
            cell.likeButtonOutlet.hideLoading()
            print("deadBeef didPressLikeButton uid is nil so terminating")
            return
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("deadBeef mfTVC dPLB() couldnt get indexPath from didPressLikeButtondDelegate")
            return
        }
        
        let index = indexPath[1]
        let product = productArray[index]
        
        //If the user isn't logged in yet
        if uid != nil && cell.currentState == .notLiked {
            print("deadBeef mfTVC dPLB() uid is not nil and product is currently not liked (dPLB in mfTVC)")
            DispatchQueue.global().async { [weak weakSelf = self] in
                weakSelf?.likedProductService.like(product: product, uid: (weakSelf?.uid!)!, productArrayToUpdate: (weakSelf?.productArray)!) { success in
                    if success {
                        cell.wasTapped = true
                        cell.currentState = .liked
                        AnalyticsManager.sharedInstance.sendProductLikedEvent(product: product, userLocation: weakSelf?.userLocation)
                    } else if !success {
                        cell.currentState = .notLiked
                        AnalyticsManager.sharedInstance.sendProductUnlikedEvent(product: product, userLocation: weakSelf?.userLocation)
                    }
                }
            }
        } else if uid != nil && cell.currentState == .liked {
            print("deadBeef mfTVC dPLB() uid is not nil and state of cell is .liked (dPLB in mfTVC)")
            DispatchQueue.global().async { [weak weakSelf = self] in
                weakSelf?.likedProductService.deleteLiked(product: product, uid: (weakSelf?.uid!)!, productArrayToDeleteFrom: (weakSelf?.productArray)!) { (success, reload) in
                    if success {
                        cell.wasTapped = true
                        cell.currentState = .notLiked
                        print("deadBeef mfTVC dPLB() deleted product")
                    } else if !success {
                        //try again
                        cell.currentState = .liked
                        print("deadBeef mfTVC dPLB() failed to delete product")
                    }
                }
            }
        }
    }
}

extension MainFeedTVC: NetworkStatusListener {
    
    //If reachability screws up it may be because of the queue's
    func networkStatusDidChange(status: Reachability.Connection) {
        print("deadBeef mfTVC_nSDC listener: \(status)")
        
        DispatchQueue.main.async { [weak weakSelf = self] in
            switch status {
            case .none:
                weakSelf?.networkStatusIndicator.showNoNetworkIndicator()
                weakSelf?.networkIsAvailable = false
            case .cellular:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
                weakSelf?.networkIsAvailable = true
            case .wifi:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
                weakSelf?.networkIsAvailable = true
            }
        }
    }
}

extension MainFeedTVC: DidSetFilterDelegate {
    
    func didSetFilter(filterString: String) {
        
        print("deadBeef mfTVC received filterString: \(filterString)")
        productSearcher.query.filters = filterString
        searchController.searchBar.text = nil
        displayProducts("")
        filterButtonOutlet.changeState(accordingTo: filterString)
    }
}

extension MainFeedTVC {
    
    //MARK: BackButtonTitle functions
    
    func setBackButtonText() {
        
        //set backButton text, which is defined by the title of the source VC
        print("deadBeef 11 current title before segue: \(currentBackButtonTitle)")
        
        guard currentBackButtonTitle != nil else {
            print("deadBeef 11 currentBackButtonTitle was nil in setBackButtonText()")
            return
        }
        
        let title = currentBackButtonTitle
        print("deadBeef 11 currentBackButtonTitle is \(title)")
        guard title != "Back" else {
            print("deadBeef 11 title was `back`, exited setBackButtonText()")
            return
        }
        guard let componentsOfTitle = title?.components(separatedBy: ": ") else {
            print("deadBeef 11 couldnt get currentFacet for title")
            return
        }
        print("deadBeef 11 currentFacetArray count: \(componentsOfTitle.count)")
        guard componentsOfTitle.count > 1 else {
            //When `Clear Filters is tapped in fVC, the title text is set to ClearedAll. This triggers this code here`
            print("deadBeef 11 setting backButtonText to back")
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            navigationItem.backBarButtonItem = backButton
            return
        }
        let currentFacet = componentsOfTitle[1]
        
        let backButton = UIBarButtonItem()
        backButton.title = "Current: \(currentFacet)"
        navigationItem.backBarButtonItem = backButton
    }
    
    func getAndResetCurrentBackBarButtonTitle() {
        
        let title = self.navigationItem.backBarButtonItem?.title
        print("deadBeef 11 title in gARCBBBT: \(title)")
        
        guard title != nil else {
            print("deadBeef 11 title was nil, exiting gARCBBBT")
            return
        }
        
        //Capture title if it is a filter or `ClearedAll` as the filters have been cleared and then...
        if title != "Back" {
            currentBackButtonTitle = title
            self.navigationItem.backBarButtonItem?.title = "Back"
        }
        
        //...Reset the button title and cBBT if the title was `ClearedAll`
        else if title == "ClearedAll" {
            self.navigationItem.backBarButtonItem?.title = "Back"
            currentBackButtonTitle = "Back"
        }
    }
}

