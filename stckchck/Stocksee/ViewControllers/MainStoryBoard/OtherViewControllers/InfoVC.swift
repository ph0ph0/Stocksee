//
//  InfoVC.swift
//  stckchck
//
//  Created by Pho on 24/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Crashlytics
import Firebase

class InfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UITextView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet var sexTypeLabels: [UILabel]!
    @IBOutlet weak var maleSwitch: UISwitch!
    @IBOutlet weak var femaleSwitch: UISwitch!
    @IBOutlet weak var sendButtonOutlet: LoadableSubmitButton!
    @IBOutlet weak var agePicker: UIPickerView!
    @IBOutlet weak var termsStackView: UIStackView!
    @IBOutlet var termsButtonOutlet: CheckboxButton!
    @IBOutlet var privacyButtonOutlet: CheckboxButton!
    
    var ageData = [String]()
    var uid: String?
    var registeredViaFB = false
    var userLocation: (lat: Double, lng: Double)?
    
    @IBAction func unwindToInfoVC(segue:UIStoryboardSegue) { }
    
    @IBAction func termsCheckbox(_ sender: CheckboxButton) {
        sender.changeState()
    }
    @IBAction func privacyCheckbox(_ sender: CheckboxButton) {
        sender.changeState()
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        sendButtonOutlet.showLoading()
        
        if RemoteConfigManager.sharedInstance.shouldShowBYandSexAsCompulsory(forKey: .BYandSexAreCompulsory) {
            
            print("deadBeef RC_ BY and Sex are not compulsory")
            
            guard ageData[agePicker.selectedRow(inComponent: 0)] != "Year" else {
                alertMessage("Almost there!", message: "Please select your birth year")
                sendButtonOutlet.hideLoading()
                return
            }
            
            guard maleSwitch.isOn || femaleSwitch.isOn else {
                alertMessage("Nearly done!", message: "Please select your sex")
                sendButtonOutlet.hideLoading()
                return
            }
        }
        
        if privacyButtonOutlet.current == .dormant && privacyButtonOutlet.current == .dormant {
            sendButtonOutlet.hideLoading()
            privacyButtonOutlet.current = .highlighted
            termsButtonOutlet.current = .highlighted
            print("deadBeef wVC_sB checkbox not ticked")
            return
        }
        
        if termsButtonOutlet.current == .dormant || termsButtonOutlet.current == .highlighted {
            sendButtonOutlet.hideLoading()
            termsButtonOutlet.current = .highlighted
            print("deadBeef wVC_sB checkbox not ticked")
            return
        }
        
        if privacyButtonOutlet.current == .dormant || privacyButtonOutlet.current == .highlighted {
            sendButtonOutlet.hideLoading()
            privacyButtonOutlet.current = .highlighted
            print("deadBeef wVC_sB checkbox not ticked")
            return
        }
        
        guard let uid = uid else {
            alertMessage("Hold on a minute...", message: "Can you please try submitting that again, there was an internal error!")
            self.uid = Auth.auth().currentUser?.uid
            sendButtonOutlet.hideLoading()
            return
        }
        
        let userRef = databaseRef.collection("UserInfo").document(uid)
        
        let selectedYear = ageData[agePicker.selectedRow(inComponent: 0)]
        var birthYear = Int()
        if selectedYear == "Year" {
            print("deadBeef")
            birthYear = 0
        } else {
            birthYear = Int(selectedYear)!
        }
        
        var sex = "N/A"
        
        if maleSwitch.isOn {
            sex = "Male"
        } else if femaleSwitch.isOn {
            sex = "Female"
        }
        
        let userInfo: [String: Any] = [
            "BirthYear": birthYear,
            "Sex": sex,
            "AgreedToTs&Cs" : true,
            "AgreedToPrivacyPolicy" : true
        ]
        
        DispatchQueue.global().async {
            userRef.setData(userInfo) { [weak weakSelf = self] (error) in
                print("deadBeef iVC_submitButton setting userInfo")
                if error == nil {
                    weakSelf?.sendButtonOutlet.hideLoading()
                    
                    //set UserInfoManager
                    UserInfoManager.sharedInstance.setUserInfo(userBirthYear: birthYear, userSex: sex, uid: uid)
                    
                    //Answers Analytics
                    if (weakSelf?.registeredViaFB)! {
                        AnalyticsManager.sharedInstance.sendSignUpEventToAnalytics(signedUpVia: "facebook", userLocation: weakSelf?.userLocation)
                    } else if !(weakSelf?.registeredViaFB)! {
                        AnalyticsManager.sharedInstance.sendSignUpEventToAnalytics(signedUpVia: "email", userLocation: weakSelf?.userLocation)
                    }
                    
                    
                    //Dismiss login navStack
                    weakSelf?.dismiss(animated: true, completion: nil)
                    
                } else if error != nil {
                    weakSelf?.sendButtonOutlet.hideLoading()
                    weakSelf?.alertMessage("Sorry!", message: "There was an error completing the request, please try again!")
                }
            }
        }
        
    }
    
    deinit {
        print("deadBeef iVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        print(disclaimerLabel.text)
        if RemoteConfigManager.sharedInstance.fetchComplete {
            print("deadBeef RC_ current RC compulsoryData setting: \(RemoteConfigManager.sharedInstance.shouldShowBYandSexAsCompulsory(forKey: .BYandSexAreCompulsory))")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        registeredViaFB = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoToTermsSegue" {
            let destination = segue.destination as? TermsVC
            destination?.previousVC = .Info
        }
    }
    
    func setupUI() {
        
        for number in 1920...2002 {
            let stringNumber = "\(number)"
            ageData.append(stringNumber)
        }
        ageData.append("Year")
        
        print("deadBeef ageData: \(ageData)")
        
        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.showsSelectionIndicator = false
        agePicker.selectRow(83, inComponent: 0, animated: true)
        
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 22)
        disclaimerLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        disclaimerLabel.isEditable = false
        disclaimerLabel.isSelectable = false
        disclaimerLabel.isScrollEnabled = true
        ageLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        sexLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        
        //If remote config is set that sex and BY are not compulsory, they should be stated as optional (ie false = optional)
        if !RemoteConfigManager.sharedInstance.shouldShowBYandSexAsCompulsory(forKey: .BYandSexAreCompulsory) {
            sexLabel.text = sexLabel.text! + " (optional)"
            ageLabel.text = ageLabel.text! + " (optional)"
        }
        
        for sexLabelType in sexTypeLabels {
            sexLabelType.font = UIFont(name: "AvenirNext-Regular", size: 15)
        }
        
        let textFieldAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-UltraLight", size: 18)!
        ]
        
        sendButtonOutlet!.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        sendButtonOutlet.setTitle("Submit", for: .normal)
        
        disclaimerLabel.text = setText()
        
        maleSwitch.addTarget(self, action: #selector(maleSwitchValueDidChange(_:)), for: .valueChanged)
        femaleSwitch.addTarget(self, action: #selector(femaleSwitchValueDidChange(_:)), for: .valueChanged)
        
    }
    
    @objc func maleSwitchValueDidChange(_ sender: UISwitch) {
        if maleSwitch.isOn {
            femaleSwitch.setOn(false, animated: true)
        }
    }
    
    @objc func femaleSwitchValueDidChange(_ sender: UISwitch) {
        if femaleSwitch.isOn {
            maleSwitch.setOn(false, animated: true)
        }
    }
    
    func setText() -> String {
        let text = """
        At Stocksee, we value your privacy. The data we collect here is used to provide you with the best service possible so that we can help you find the products that you want, when you want them. Please see the Privacy and Terms of Use at the bottom of the screen for more info.
        """
        return text
    }
    
}

extension InfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        agePicker.subviews.forEach({
            
            $0.isHidden = $0.frame.height < 1.0
        })

        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ageData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = ageData[row]
        let titleAttributes = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return titleAttributes
    }
}
