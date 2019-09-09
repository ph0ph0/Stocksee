//
//  ProductDetailVC.swift
//  stckchck
//
//  Created by Pho on 24/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Reachability
import Crashlytics
import Firebase
import Mapbox

class ProductDetailVC: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {
    
    
    @IBOutlet var productDetailVCFrame: UIView!
    @IBOutlet var productDFTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MGLMapView?
    @IBOutlet weak var findingLocationIndicator: NetworkStatusIndicator!
    @IBOutlet var userLocationButton: UserLocationButton!
    @IBAction func locationButtonTapped(sender: UserLocationButton) {
        var mode: MGLUserTrackingMode
        var modeDescription: String
        
        print("deadBeef IGLK productFeed product \(String(describing: productDetailFeed?.product.first?.brand!))")
        
        print("deadBeef userLocationButton mode before changing: \(sender.currentMode.rawValue)")
        
        guard let unwrappedMapView = mapView else {
            print("deadBeef aborting mapView is nil")
            return
        }
        
        switch (unwrappedMapView.userTrackingMode) {
        case .none:
            mode = .follow
            modeDescription = "follow"
            break
        case .follow:
            mode = .followWithHeading
            modeDescription = "followWithHeading"
            break
        case .followWithHeading:
            mode = .none
            modeDescription = "none from fWH"
            break
        case .followWithCourse:
            mode = .none
            modeDescription = "none from fWC"
            break
        }
        
        print("deadBeef changed tracking mode to: \(modeDescription)")
        unwrappedMapView.userTrackingMode = mode
        sender.updateArrowForTrackingMode(mode: mode)
    }
    
    var product: Product?
    var locationManager = CLLocationManager()
    var shopPlacemark: MKPlacemark?
    var shopMapAnnotation = MGLPointAnnotation()
    lazy var geoCoder = CLGeocoder()
    var shopCLLocationCoordinate2D: CLLocationCoordinate2D?
    var locationFound = false
    let polyline = Polyline()
    var productDetailFeed: ProductDetailFeed?
    var currentUserLocation: (lat: Double, lng: Double)?
    var destinationReached = false
    
    //viewWillLayoutSubviews is called each time a change to the constraints occurs. Therefore we have to check if the first layout has been done, otherwise the pDF will be stuck at the bottom as it will be reset to this position in the vWLS
    var firstLayoutDone = false
    var restingPosition: CGFloat = 75
    
    //MARK: vDL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Load products
        configureUI(product: product)
        print("deadBeef IGLK \(self.childViewControllers)")
        productDetailFeed = childViewControllers.first as! ProductDetailFeed
        
        guard let unwrappedMapView = mapView else {
            print("deadBeef aborting mapView is nil")
            return
        }
        
        //MARK: Location services setup
        unwrappedMapView.delegate = self
        unwrappedMapView.userTrackingMode = .followWithHeading
        unwrappedMapView.compassView.isHidden = true
        unwrappedMapView.showsUserLocation = true
        unwrappedMapView.showsUserHeadingIndicator = true
        setUpLocationButton()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: vDA/vWD
    override func viewWillAppear(_ animated: Bool) {
        
        print("deadBeef price \(product?.price)")
        
        AnalyticsManager.sharedInstance.sendProductDetailViewedEvent(product: product, userLocation: currentUserLocation)
        
        ReachabilityManager.sharedInstance.addListener(listener: self)
        print("deadBeef pdVC_vwA ReachabilityStatus: \(ReachabilityManager.sharedInstance.reachabilityStatus)")
        
        findingLocationIndicator.removeLocationIndicator()
        if ReachabilityManager.sharedInstance.reachabilityStatus == .none {
            findingLocationIndicator.showNoNetworkIndicator()
            return
        }
        findingLocationIndicator.showFindingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ReachabilityManager.sharedInstance.removeListener(listener: self)
        locationManager.stopUpdatingHeading()
        shopCLLocationCoordinate2D = nil
        
        guard let unwrappedMapView = mapView else {
            print("deadBeef aborting mapView is nil")
            return
        }
        
        //Need to get rid of the MapView otherwise it eats memory and can cause crashes
        unwrappedMapView.showsUserLocation = false
        unwrappedMapView.delegate = nil
        unwrappedMapView.removeFromSuperview()
        mapView = nil
    }
    
    override func viewDidLayoutSubviews() {
        //Set the productDetailFeed to its resting position, check if the first layout has been done already.
        if !firstLayoutDone {
            view.layoutIfNeeded()
            let topConstraintConstant = view.bounds.height - restingPosition
            productDFTopConstraint.constant = topConstraintConstant
            view.setNeedsUpdateConstraints()
            view.layoutIfNeeded()
            firstLayoutDone = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbededProductDetail" {
            print("deadBeef IGLK showing pdF")
            let productDetailFeed = segue.destination as! ProductDetailFeed
            //Delegate that recognises that the pdF was dismissed
            productDetailFeed.didDismissPDFDelegate = self
            //Delegate that recognises a tap on the title cell and shows the pdF
            productDetailFeed.shouldShowProductDetailDelegate = self
            productDetailFeed.product.append(product!)
        }
    }
}

//MARK: Product Loader

extension ProductDetailVC {
    
    fileprivate func configureUI(product: Product?) {
        
        guard let productToShow = product else {
            print("deadBeef no product passed from main feed")
            return
        }
        
        guard let productGeo = productToShow._geoloc else {
            print("deadBeef failed to get geoloc for display")
            return
        }
        
        guard let productLat = productGeo["lat"] as? Double, let productLng = productGeo["lng"] as? Double else {
            print("deadBeef failed to get product lat and lng")
            return
        }
        
        let shopCLLocationCoordinate2D = CLLocationCoordinate2DMake(productLat, productLng)
        
        shopPlacemark = MKPlacemark(coordinate: shopCLLocationCoordinate2D, addressDictionary: nil)
        print("deadBeef shopPlacemark: \(String(describing: shopPlacemark))")
    }
}

//MARK: Location Services

extension ProductDetailVC {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Show the finding location indicator
        if !findingLocationIndicator.isDescendant(of: self.view) && !locationFound {
            findingLocationIndicator.showFindingLocation()
        }
        
        guard let lastLocation = locations.last else {
            print("deadBeef couldnt get last location")
            return
        }
        
        let userLocation = lastLocation
        print("deadBeef user location: \(userLocation)")
        
        geoCoder.reverseGeocodeLocation(userLocation) { [weak weakSelf = self] (placemarks: [CLPlacemark]?, error) in
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard error == nil else {
                    print("deadBeef aborting error reverse geocoding: \(error)")
                    return
                }
                
                guard let unwrappedMapView = weakSelf?.mapView else {
                    print("deadBeef aborting mapView is nil")
                    return
                }
                
                guard let unwrappedShopPlacemark = weakSelf?.shopPlacemark else {
                    print("deadBeef aborting shopPlacemark was nil")
                    return
                }
                
                guard let unwrappedProduct = weakSelf?.product else {
                    print("deadBeef aborting product was nil")
                    return
                }
                
                //Get the user placemark
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    print("deadBeef userLocation placemark: \(placemark)")
                    
                    //Create the dictionary to access the address contained within the placemark
                    var addressDictionary = [String: Any]()
                    addressDictionary["name"] = placemark.name
                    addressDictionary["thoroughfare"] = placemark.thoroughfare
                    addressDictionary["subThoroughdare"] = placemark.subThoroughfare
                    addressDictionary["locality"] = placemark.locality
                    addressDictionary["postalCode"] = placemark.postalCode
                    addressDictionary["country"] = placemark.country
                    
                    //Convert the user placemark to a mapItem (address).
                    let userLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: (placemark.location?.coordinate)!, addressDictionary: addressDictionary))
                    print("deadBeef userLocationMapItem: \(userLocationMapItem)")
                    
                    let userLat = placemark.location?.coordinate.latitude
                    let userLng = placemark.location?.coordinate.longitude
                    weakSelf?.currentUserLocation = (userLat, userLng) as? (lat: Double, lng: Double)
                    
                    
                    //Convert the shop location to a mapItem (address)
                    let shopLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: ((unwrappedShopPlacemark.location?.coordinate)!), addressDictionary: addressDictionary))
                    
                    //Get the lat and long of the product.
                    guard let productGeo = unwrappedProduct._geoloc else {
                        print("deadBeef aborting failed to get geolocation for display")
                        return
                    }
                    
                    guard let productLat = productGeo["lat"] as? Double, let productLng = productGeo["lng"] as? Double else {
                        print("deadBeef aborting couldn't get product coordinates from productGeo")
                        return
                    }
                    
                    
                    //Add the location of the shop as an annotation
                    if weakSelf?.shopCLLocationCoordinate2D == nil {
                        weakSelf?.shopCLLocationCoordinate2D = CLLocationCoordinate2DMake(productLat, productLng)
                        print("deadBeef shopLat and Lng: \(productLat, productLng)")
                        print("deadBeef making shopMapAnnotation from shopCLLocationCoordinate2D")
                        weakSelf?.shopMapAnnotation.coordinate = (weakSelf?.shopCLLocationCoordinate2D)!
                        print("deadBeef shopMapAnnotation.coordinate: \(weakSelf?.shopMapAnnotation.coordinate)")
                        print("deadBeef mapViewAnnotations \(unwrappedMapView.annotations)")
                        weakSelf?.shopMapAnnotation.title = weakSelf?.product?.shopName
                        
                        //The annotations MUST be added on the main queue or the app will crash!
                        DispatchQueue.main.async {
                            unwrappedMapView.addAnnotation((weakSelf?.shopMapAnnotation)!)
                        }
                        
                    }
                    
                    //Get directions to the shop
                    let request = MKDirectionsRequest()
                    request.source = userLocationMapItem
                    request.destination = shopLocationMapItem
                    request.transportType = .walking
                    
                    let directions = MKDirections(request: request)
                    directions.calculate { (response, error) in
                        
                        guard let unwrappedResponse = response else {
                            print("deadBeef aborting failed to get directions response")
                            return
                        }
                        
                        //Get the suggested route. Note how we haven's asked for alternative routes.
                        let route = unwrappedResponse.routes[0]
                        
                        DispatchQueue.main.async { [weak weakSelf = self] in
                            
                            guard let unwrappedLocationFound = weakSelf?.locationFound, let destinationReached = weakSelf?.destinationReached else {
                                print("deadbeef couldnt get location found")
                                return
                            }
                            
                            if !unwrappedLocationFound {
                                weakSelf?.findingLocationIndicator.showFoundLocation()
                            } else {
                                print("deadBeef already shown findingLocationIndicator")
                            }
                            
                            //This is an extension to MKMultiPoint and can be found in MapExtensions.swift
                            let coordinates: [CLLocationCoordinate2D]? = route.polyline.coordinates
                            guard let unwrappedCoordinates = coordinates else {
                                print("deadBeef aborting coordinates to draw polyline were nil, aborting")
                                return
                            }
                            print("deadBeef coordinates count: \(unwrappedCoordinates.count)")
                            
                            //If the polyline has already been drawn, we want to draw it, if not, we want to update it
                            guard let unwrappedPolyline = weakSelf?.polyline else {
                                print("deadBeef aborting polyline was nil")
                                return
                            }
                            if !(unwrappedPolyline.hasBeenDrawn) {
                                print("deadBeef drawing polyline")
                                weakSelf?.polyline.addPolyline(to: unwrappedMapView.style, with: unwrappedCoordinates)
                            } else if (unwrappedPolyline.hasBeenDrawn) {
                                weakSelf?.polyline.updatePolyline(with: unwrappedCoordinates)
                            }
                            
                            weakSelf?.locationFound = true
                            
                            print("deadBeef DT distance to destination is: \(route.distance)")
                            
                            if route.distance < 90 && !destinationReached {
                                print("deadBeef DT destination reached")
                                AnalyticsManager.sharedInstance.sendDestinationReached(product: weakSelf?.product)
                                weakSelf?.destinationReached = true
                            }
                            
                            print("deadBeef mapViewAnnotations: \(String(describing: unwrappedMapView.annotations))")
                            
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("deadBeef locationManager failed to get location: \(error)")
    }
    
}

extension ProductDetailVC: NetworkStatusListener {
    
    //If reachability screws up it may be because of the queue's
    func networkStatusDidChange(status: Reachability.Connection) {
        print("deadBeef mfTVC_nSDC listener: \(status)")
        
        DispatchQueue.main.async { [weak weakSelf = self] in
            switch status {
            case .none:
                weakSelf?.findingLocationIndicator.showNoNetworkIndicator()
            case .cellular:
                weakSelf?.findingLocationIndicator.showFindingLocation()
                weakSelf?.locationManager.requestLocation()
            case .wifi:
                weakSelf?.findingLocationIndicator.showFindingLocation()
                weakSelf?.locationManager.requestLocation()
            }
        }
    }
    
}

//MARK: MapBox functions

extension ProductDetailVC {
    
    func setUpLocationButton() {
        
        guard let unwrappedMapView = mapView else {
            print("deadBeef aborting mapView is nil")
            return
        }
        
        userLocationButton = UserLocationButton(buttonSize: 40)
        userLocationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        userLocationButton.tintColor = unwrappedMapView.tintColor
        view.addSubview(userLocationButton)
        
        // Setup constraints such that the button is placed within the upper right corner of the view.
        
        userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            NSLayoutConstraint(item: userLocationButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: userLocationButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: userLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.height),
            NSLayoutConstraint(item: userLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.width)
        ]
        
        view.addConstraints(constraints)
    }
    
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        //We detect if the tracking mode has changed, which can occur if the user pans away from the user marker on the map
        guard let userLocationButton = userLocationButton else {
            print("deadBeef userLocationButton not yet instantiated")
            return
        }
        
        // We have a willSet in the .current mode property that updates the arrow
        userLocationButton.currentMode = mode
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "LocationMarker")
        
        if annotationImage == nil {
            var image = UIImage(named: "LocationMarker")!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height. Note that this means that the LocationMarker image has been made
            // to be twice its expected height; half is transparent.
            // To make the padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            
            
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            
            // Initialize theannotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "LocationMarker")
        }
        
        return annotationImage
    }
}

extension ProductDetailVC: DidDismissPDFDelegate, ShouldShowPDFDelegate {
    
    func showProductDetail() {
        
        print("deadBeef IGLK shouldShowPDFDelegate")
        let topConstraintConstant: CGFloat = 87
        DispatchQueue.main.async { [weak weakSelf = self] in
            
            weakSelf?.view.setNeedsUpdateConstraints()
            weakSelf?.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: { [weak weakSelf = self] in
                            weakSelf?.productDFTopConstraint.constant = topConstraintConstant
                            weakSelf!.productDetailVCFrame.setNeedsUpdateConstraints()
                            weakSelf?.view.layoutIfNeeded()
                },
                           completion: nil)
            
            
        }
    }
    
    
    func didDismissPDF() {
        print("deadBeef IGLK didDismissPDFDelegate")
        let topConstraintConstant = view.bounds.height - restingPosition
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.view.setNeedsUpdateConstraints()
            weakSelf?.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: { [weak weakSelf = self] in
                            weakSelf?.productDFTopConstraint.constant = topConstraintConstant
                            weakSelf!.productDetailVCFrame.setNeedsUpdateConstraints()
                            weakSelf?.view.layoutIfNeeded()
                },
                           completion: nil)
        }
    }
}
