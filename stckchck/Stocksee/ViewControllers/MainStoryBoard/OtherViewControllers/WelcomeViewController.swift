//
//  WelcomeViewController.swift
//  stckchck
//
//  Created by Pho on 29/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import UIKit
import FirebaseAuth
import Reachability
import Crashlytics
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class WelcomeViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    fileprivate enum state {
        case login
        case register
    }
    
    fileprivate var current = state.login {
        willSet {
            guard let submitButton = submitButtonOutlet, let facebookButton = facebookButtonOutlet, let googleButton = googleSignInButtonOutlet else {
                print("deadBeef wVC submitButton not yet instantiated")
                return
            }
            if newValue == .login {
                submitButton.setTitle("Login", for: .normal)
                facebookButton.setTitle("Sign in with Facebook", for: .normal)
                googleButton.setTitle("Sign in with Google", for: .normal)
            } else if newValue == .register {
                submitButton.setTitle("Register", for: .normal)
                facebookButton.setTitle("Sign up with Facebook", for: .normal)
                googleButton.setTitle("Sign up with Google", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButtonOutlet: LoadableSubmitButton?
    @IBOutlet weak var passwordButtonOutlet: UIButton!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    @IBOutlet weak var networkStatusIndicator: NetworkStatusIndicator!
    
    @IBAction func unwindToWelcome(segue: UIStoryboardSegue) {}
    
    lazy var activityIndicator = UIActivityIndicatorView()
    var uid: String?
    var registeredViaFB = false
    var userLocation: (lat: Double, lng: Double)?
    
    @IBOutlet weak var facebookButtonOutlet: LoadableSubmitButton!
    
    @IBOutlet weak var facebookDisclaimerOutlet: UILabel!
    
    @IBAction func facebookButton(_ sender: LoadableSubmitButton) {
        
        sender.showLoading()
        
        let loginManager = FBSDKLoginManager()
        print("deadBeef FF token at start: \(String(describing: FBSDKAccessToken.current()))")
        //Race condition?
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { [weak weakSelf = self] (result, error) in
            print("deadBeef FF result: \(String(describing: result)), error: \(String(describing: error))")
            if let error = error {
                weakSelf?.alertMessage("Facebook isn't working...", message: "We couldn't log you in via Facebook, please try again")
                print("deadbeef FF wVC_facebookButton  error logging in/signing up: \(error.localizedDescription)")
                AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "loginManager error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                sender.hideLoading()
                return
            }
            print("deadBeef FF RESULT: \(String(describing: result))")
            print("deadBeef FF access token: \(String(describing: FBSDKAccessToken.current())), tokenString: \(String(describing: FBSDKAccessToken.current()?.tokenString))")
            guard let accessToken = FBSDKAccessToken.current() else {
                weakSelf?.alertMessage("For goodness sake, Facebook isn't working...", message: "We couldn't log you in via Facebook, please try again, perhaps using your email address and password when hinted in the Facebook login flow")
                print("deadBeef FF wVC_facebookButton error getting access token, error: \(String(describing: error))")
                AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "accessToken error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                sender.hideLoading()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print("deadBeef FF wVC_facebookButton failed to make Firebase Link: \(error.localizedDescription)")
                    if error.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address." {
                        weakSelf?.alertMessage("Wait a second... You already have an account!", message: "It seems as though you already have an account associated with this email address. Please log in using this email address, instead of Facebook login.")
                    }
                    AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "firebaseLink error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                    sender.hideLoading()
                    return
                }
                
                guard let isNewUser = authResult?.additionalUserInfo?.isNewUser else {
                    print("deadBeef FF wVC_facebookButton Delegate no isNewUser in additionalUserInfo")
                    AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "isNewUser error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                    sender.hideLoading()
                    return
                }
                
                if isNewUser {
                    print("deadBeef FF wVC_facebookButton Delegate isNewUser, segueing to iVC")
                    
                    guard let authResult = authResult else {
                        print("deadBeef FF wVC_facebookButton failed to get authResult")
                        AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "isNewUser authResult error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                        sender.hideLoading()
                        return
                    }
                    
                    weakSelf?.uid = authResult.user.uid
                    
                    print("deadBeef FF wVC registered uid: \(String(describing: weakSelf?.uid))")
                    
                    sender.hideLoading()
                    
                    //Log User into Crashlytics
                    Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                    Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                    
                    weakSelf?.registeredViaFB = true
                    weakSelf?.performSegue(withIdentifier: "WelcomeToLoadingInfoVC", sender: self)
                    
                } else if !isNewUser {
                    print("deadBeef FF wVC_facebookButton Delegate returning user, segueing to iVC")
                    
                    guard let authResult = authResult else {
                        print("deadBeef FF wVC_facebookButton failed to get authResult")
                        AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "!isNewUser loginManager error", loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                        sender.hideLoading()
                        return
                    }
                    
                    weakSelf?.uid = authResult.user.uid
                    
                    print("deadBeef FF wVC logged in uid: \(String(describing: weakSelf?.uid))")
                    
                    sender.hideLoading()
                    
                    //Log User into Crashlytics
                    Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                    Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                    
                    //Set UserInfoManager
                    weakSelf?.setUserInfoManager()
                    
                    //Send Analytics
                    AnalyticsManager.sharedInstance.sendLogInEventToAnalytics(loggedInVia: "facebook", userLocation: weakSelf?.userLocation)
                    
                    weakSelf?.dismiss(animated: true, completion: {
                        //print("deadBeef wVC_Login FF indexOfProductToUpdate: \(String(describing: weakSelf?.indexOfProductToUpdate))")
                        
                    })
                }
            }
        }
    }
    
    @IBOutlet var googleSignInButtonOutlet: LoadableSubmitButton!
    @IBAction func GoogleSignInButton(_ sender: LoadableSubmitButton) {
        
        googleSignInButtonOutlet.showLoading()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    override func viewDidLoad() {
        
        uid = Auth.auth().currentUser?.uid
        print("deadBeef wVC_vDL uid: \(String(describing: uid))")
        //print("deadBeef wVC_vDL indexOfProductToUpdate: \(String(describing: indexOfProductToUpdate))")
        
        //MARK: UISetup
        setUI()
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        //MARK: ActivityIndicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .white
        view.addSubview(activityIndicator)
        
    }
    
    //MARK: vWA/vWD
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Since the login vC's are in a navCon, we need to hide the navBar
        self.navigationController?.isNavigationBarHidden = true
        
        networkStatusIndicator.removeNetworkStatusIndicator()
        if ReachabilityManager.sharedInstance.reachabilityStatus == .none {
            networkStatusIndicator.showNoNetworkIndicator()
        }
        ReachabilityManager.sharedInstance.addListener(listener: self)
        print("deadBeef fbsubviews: \(facebookButtonOutlet.subviews)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ReachabilityManager.sharedInstance.removeListener(listener: self)
    }
    
    //MARK: UI Setup
    
    //This is a helper function that adds the social media logos to the social media buttons
    func setupLogoImageViewFor(button: LoadableSubmitButton, logo: UIImage) -> UIImageView {
        
        let logoImageView = UIImageView()
        let x = (((button.titleLabel?.frame.minX)!) - 12) - 100
        let y = ((button.titleLabel?.frame.minY)!) - 12
        logoImageView.frame = CGRect(x: x, y: y, width: 24, height: 24)
        logoImageView.image = logo
        logoImageView.clipsToBounds = false
        logoImageView.contentMode = .scaleAspectFit
        
        return logoImageView
    }
    
    fileprivate func setUI() {
        
        
        let textFieldAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-UltraLight", size: 18)!
        ]
        
        emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: textFieldAttributes)
        emailAddressTextField.font = UIFont(name: "AvenirNext-Regular", size: 18)
        
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: textFieldAttributes)
        passwordTextField.font = UIFont(name: "AvenirNext-Regular", size: 18)
        
        submitButtonOutlet!.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        
        facebookButtonOutlet!.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        let fbLogo = UIImage(named: "flogo-HexRBG-Wht-58")
        let fbLogoIV = setupLogoImageViewFor(button: facebookButtonOutlet, logo: fbLogo!)
        facebookButtonOutlet.addSubview(fbLogoIV)
        
        let googleLogo = UIImage(named: "GoogleLoginLogo")
        let googleLogoForButton = setupLogoImageViewFor(button: googleSignInButtonOutlet, logo: googleLogo!)
        googleSignInButtonOutlet.addSubview(googleLogoForButton)
        
        facebookDisclaimerOutlet.font = UIFont(name: "AvenirNext-Regular", size: 13)
        
        passwordButtonOutlet.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        passwordButtonOutlet.contentHorizontalAlignment = .right
        
        registerButtonOutlet.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15)
        registerButtonOutlet.contentHorizontalAlignment = .left
        
        
    }
    
    //MARK: Text Field First Responder
    //Switch from emailTextField to passwordTextField when Done is pressed, then dismiss keyboard after pwTF.
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
            
        case 1:
            if let passwordTextField = textField.superview?.viewWithTag(2) {
                passwordTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        case 2:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
        
    }
}

//MARK: Register Button State Switch

extension WelcomeViewController {
    
    @IBAction func registerButton() {
        
        switch current {
        case .login:
            print("deadBeef current state was: \(current)")
            current = .register
            registerButtonOutlet.setTitle("Login", for: .normal)
            print("deadBeef current state is now: \(current)")
        case .register:
            print("deadBeef current state was: \(current)")
            current = .login
            registerButtonOutlet.setTitle("Register", for: .normal)
            print("deadBeef current state is now: \(current)")
        }
    }
}

//MARK Login and Register

extension WelcomeViewController {
    
    @IBAction func submitButton(_ sender: LoadableSubmitButton) {
        
        self.dismissKeyboard()
        
        //submit button can be force unwrapped as it has to be instantiated to be tapped
        submitButtonOutlet!.showLoading()
        
        //Text Entry Check
        
        if emailAddressTextField.text == "" || passwordTextField.text == "" {
            submitButtonOutlet!.hideLoading()
            alertMessage("Hold your horses!", message: "Please ensure all text fields are complete.")
            return
        }
        
        if isValidEmail(emailAddressTextField.text!) == false {
            submitButtonOutlet!.hideLoading()
            alertMessage("Wait a second...", message: "Please enter a valid email address")
            return
        }
        
        if (passwordTextField.text?.count)! < 6 {
            submitButtonOutlet!.hideLoading()
            alertMessage("Are you crazy???", message: "Please ensure your password is 6 characters or more")
            return
        }
        
        switch current {
            
        case .login:
            if isValidEmail(emailAddressTextField.text!) && (passwordTextField.text?.count)! >= 6 {
                
                Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) { [weak weakSelf = self] (auth, error) in
                    
                    if error == nil {
                        
                        weakSelf?.uid = auth?.user.uid
                        
                        print("deadBeef wVC logged in uid: \(String(describing: weakSelf?.uid))")
                        
                        weakSelf?.submitButtonOutlet!.hideLoading()
                        
                        //Log User into Crashlytics
                        Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                        Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                        
                        //Set UserInfoManager
                        weakSelf?.setUserInfoManager()
                        
                        //Send Analytics
                        AnalyticsManager.sharedInstance.sendLogInEventToAnalytics(loggedInVia: "email", userLocation: weakSelf?.userLocation)
                        
                        weakSelf?.dismiss(animated: true, completion: {
                            //print("deadBeef wVC_Login indexOfProductToUpdate: \(String(describing: weakSelf?.indexOfProductToUpdate))")
                            
                        })
                        
                        } else if error != nil {
                        
                        
                        
                        guard let error = AuthErrorCode(rawValue: (error?._code)!) else {
                            return
                        }
                        
                        fireErrorHandle(code: error)
                        
                        weakSelf?.submitButtonOutlet!.hideLoading()
                        
                        var loginFailureReason = ""
                        switch error {
                            case .userDisabled:
                            weakSelf?.alertMessage("What have you done to deserve this?", message: "User currently disabled")
                            loginFailureReason = "User currently disabled"
                            case .emailAlreadyInUse:
                            weakSelf?.alertMessage("Don't try tricks with me squire", message: "Email already in use. Please try a different email address")
                            loginFailureReason = "Email already in use"
                            case .wrongPassword:
                            weakSelf?.alertMessage("We all get things wrong from time to time :)", message: "Wrong password. Please try again")
                            loginFailureReason = "Wrong password"
                            case .userNotFound:
                            weakSelf?.alertMessage("Sorry, never seen you here before...", message: "User not found. Please try different login credentials")
                            loginFailureReason = "User not found"
                            case .networkError:
                            weakSelf?.alertMessage("This isn't our fault...", message: "Network error. Please try again with a better network connection")
                            loginFailureReason = "Network error"
                        default:
                            weakSelf?.alertMessage("Error", message: "Please try logging in again")
                            loginFailureReason = "Unknown"
                        }
                        //Send Analytics
                        AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: loginFailureReason, loggedInVia: "email", userLocation: weakSelf?.userLocation)
                    }
                }
            }
            
        case .register:
            if isValidEmail(emailAddressTextField.text!) && (passwordTextField.text?.count)! >= 6 {
                
                Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) { [weak weakSelf = self] (auth, error) in
                    
                    if error == nil {
                        
                        weakSelf?.uid = auth?.user.uid
                        
                        print("deadBeef wVC registered uid: \(String(describing: weakSelf?.uid))")
                        
                        weakSelf?.submitButtonOutlet!.hideLoading()
                        
                        //Log User into Crashlytics
                        Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                        Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                        
                        //Analytics
                        AnalyticsManager.sharedInstance.sendSignUpEventToAnalytics(signedUpVia: "email", userLocation: weakSelf?.userLocation)
                        
                        weakSelf?.performSegue(withIdentifier: "WelcomeToLoadingInfoVC", sender: self)
                        
                    } else if error != nil {
                        
                        guard let error = AuthErrorCode(rawValue: (error?._code)!) else {
                            return
                        }
                        
                        fireErrorHandle(code: error)
                        
                        weakSelf?.submitButtonOutlet!.hideLoading()
                        var registerFailureReason = ""
                        
                        switch error {
                        case .userDisabled:
                            weakSelf?.alertMessage("What have you done to deserve this?", message: "User currently disabled")
                            registerFailureReason = "User currently disabled"
                        case .emailAlreadyInUse:
                            weakSelf?.alertMessage("Don't try tricks with me squire", message: "Email already in use. Please try a different email address")
                            registerFailureReason = "Email already in use"
                        case .wrongPassword:
                            weakSelf?.alertMessage("We all get things wrong from time to time :)", message: "Wrong password. Please try again")
                            registerFailureReason = "Wrong password"
                        case .userNotFound:
                            weakSelf?.alertMessage("Sorry, never seen you here before...", message: "User not found. Please try different login credentials")
                            registerFailureReason = "User not found"
                        case .networkError:
                            weakSelf?.alertMessage("This isn't our fault...", message: "Network error. Please try again with a better network connection")
                            registerFailureReason = "Network error"
                        default:
                            weakSelf?.alertMessage("Error", message: "Please try logging in again")
                            registerFailureReason = "Unknown"
                        }
                        //Send Analytics
                        AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: registerFailureReason, loggedInVia: "email", userLocation: weakSelf?.userLocation)
                    }
                }
            }
        }
    }
}

extension WelcomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WelcomeToLoadingInfoVC" {
            print("deadBeef RC_ segue from welcome to loading; uid: \(uid), regViaFB: \(registeredViaFB), _geoloc: \(userLocation)")
            let destination = segue.destination as? InfoLoadingVC
            destination?.uid = uid
            destination?.registeredViaFB = registeredViaFB
            destination?.userLocation = userLocation
            
        } else if segue.identifier == "WelcomeToTermsSegue" {
            let destination = segue.destination as? TermsVC
            destination?.previousVC = .Welcome
        }
    }
}

//MARK: GoogleSignIn

extension WelcomeViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            alertMessage("Google login isn't working...", message: "We couldn't log you in via Google, please try again")
            print("deadbeef GLog wVC_GoogleLogin  error logging in/signing up: \(error.localizedDescription)")
            AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "loginManager error", loggedInVia: "google", userLocation: userLocation)
            googleSignInButtonOutlet.hideLoading()
            return
            
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { [weak weakSelf = self] (authResult, error) in
            if let error = error {
                print("deadBeef GLog wVC_GoogleLogin failed to make Firebase Link: \(error.localizedDescription)")
                if error.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address." {
                    weakSelf?.alertMessage("Wait a second... You already have an account!", message: "It seems as though you already have an account associated with this email address. Please log in using this email address, instead of Google login.")
                }
                AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "firebaseLink error", loggedInVia: "google", userLocation: weakSelf?.userLocation)
                weakSelf?.googleSignInButtonOutlet.hideLoading()
                return
            }
            
            guard let isNewUser = authResult?.additionalUserInfo?.isNewUser else {
                print("deadBeef GLog wVC_GoogleLogin Delegate no isNewUser in additionalUserInfo")
                AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "isNewUser error", loggedInVia: "google", userLocation: weakSelf?.userLocation)
                weakSelf?.googleSignInButtonOutlet.hideLoading()
                return
            }
            
            if isNewUser {
                
                guard let authResult = authResult else {
                    print("deadBeef GLog wVC_GoogleLogin failed to get authResult")
                    AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "isNewUser authResult error", loggedInVia: "google", userLocation: weakSelf?.userLocation)
                    weakSelf?.googleSignInButtonOutlet.hideLoading()
                    return
                }
                
                weakSelf?.uid = authResult.user.uid
                
                print("deadBeef GLog wVC_GoogleLogin uid: \(String(describing: weakSelf?.uid))")
                
                weakSelf?.googleSignInButtonOutlet.hideLoading()
                
                //Log User into Crashlytics
                Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                
                weakSelf?.registeredViaFB = true
                
                weakSelf?.performSegue(withIdentifier: "WelcomeToLoadingInfoVC", sender: self)
                
            } else if !isNewUser {
                print("deadBeef GLog wVC_GoogleLogin Delegate returning user, segueing to iVC")
                
                guard let authResult = authResult else {
                    print("deadBeef GLog wVC_GoogleLogin failed to get authResult")
                    AnalyticsManager.sharedInstance.sendLogInFailureEventToAnalytics(loginFailureReason: "!isNewUser loginManager error", loggedInVia: "google", userLocation: weakSelf?.userLocation)
                    weakSelf?.googleSignInButtonOutlet.hideLoading()
                    return
                }
                
                weakSelf?.uid = authResult.user.uid
                
                print("deadBeef GLog wVC_GoogleLogin in uid: \(String(describing: weakSelf?.uid))")
                
                weakSelf?.googleSignInButtonOutlet.hideLoading()
                
                //Log User into Crashlytics
                Crashlytics.sharedInstance().setUserEmail(weakSelf?.emailAddressTextField.text)
                Crashlytics.sharedInstance().setUserIdentifier(weakSelf?.uid)
                
                //Set UserInfoManager
                weakSelf?.setUserInfoManager()
                
                //Send Analytics
                AnalyticsManager.sharedInstance.sendLogInEventToAnalytics(loggedInVia: "google", userLocation: weakSelf?.userLocation)
                
                weakSelf?.dismiss(animated: true, completion: {
                    //print("deadBeef wVC_Login FF indexOfProductToUpdate: \(String(describing: weakSelf?.indexOfProductToUpdate))")
                    
                })
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}

//MARK: NetworkStatusListener

extension WelcomeViewController: NetworkStatusListener {
    
    func networkStatusDidChange(status: Reachability.Connection) {
        print("deadBeef mfTVC_nSDC listener: \(status)")
        
        DispatchQueue.main.async { [weak weakSelf = self] in
            switch status {
            case .none:
                weakSelf?.networkStatusIndicator.showNoNetworkIndicator()
            case .cellular:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
            case .wifi:
                weakSelf?.networkStatusIndicator.showNetworkConnectedTo(networkType: status)
            }
        }
    }
    
}

extension WelcomeViewController {
    
    func setUserInfoManager() {
        
        DispatchQueue.global().async { [weak weakSelf = self] in
            
            if weakSelf?.uid != nil {
                
                if !UserInfoManager.sharedInstance.propertiesSet {
                    DispatchQueue.global().async { [weak weakSelf = self] in
                        guard let uid = weakSelf?.uid else {
                            print("deadBeef mfTVC_vWA uid was nil, exiting setting the UserInfo and using the default setting")
                            return
                        }
                        let userInfoRef = databaseRef.collection("UserInfo").document(uid)
                        userInfoRef.getDocument(completion: { (snap, error) in
                            if error == nil {
                                //This will crash the everytime at startup if a user didnt complete the login process fully...
                                let userData = snap?.data() as [String: Any]?
                                let birthYear = userData?["BirthYear"] as! Int
                                print("deadBeef user BirthYear: \(birthYear)")
                                let userSex = userData?["Sex"] as! String
                                let uid = uid
                                UserInfoManager.sharedInstance.setUserInfo(userBirthYear: birthYear, userSex: userSex, uid: uid)
                            }
                        })
                    }
                }
            }
        }
    }
}





