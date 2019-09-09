//
//  TermsVC.swift
//  stckchck
//
//  Created by Pho on 21/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class TermsVC: UIViewController {
    
    enum PreviousVC {
        case Welcome
        case Info
    }
    
    var previousVC = PreviousVC.Welcome
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsTextView.text = displayText()
        termsTextView.isEditable = false
        termsTextView.isSelectable = false
        termsTextView.isScrollEnabled = true
        
    }
    
    @IBOutlet weak var termsTextView: UITextView!
    
    @IBAction func dismissButton(_ sender: Any) {
        switch previousVC {
        case .Welcome:
            print("deadBeef tVC returning to wVC")
            performSegue(withIdentifier: "TermsToWelcomeSegue", sender: self)
        case .Info:
            print("deadBeef tVC returning to iVC")
            performSegue(withIdentifier: "TermsToInfoSegue", sender: self)
        }
    }
    
    private func displayText() -> String {
        
        let text = """
        
 Privacy Policy and Terms of Use

 1. Introduction

 Stocksee is a business that has been developed using Privacy by Design. At Stocksee, we take a user-centric approach to privacy, such that it is embedded into the design of our Service. We are transparent with our users, and we value their privacy by implementing strict privacy requirements as our default settings. We are committed to safeguarding the privacy of Stocksee users and service clients.

 This Privacy Policy describes how and when Stocksee collects, uses and shares your information when you use our Services. The Stocksee application receives your information through your usage of the application. We collect and use your information to provide our Services and to measure and improve our Services from time to time. When using any of our Services you consent to the collection, transfer, manipulation, storage, disclosure and other uses of your information as described in this Privacy Policy. As such, stckchck Ltd (the owner of Stocksee) acts as a Data Controller and Data Processor, as defined by GDPR. Irrespective of which country you reside in or supply information from, you authorise stckchck Ltd to use your information in the UK and any other country where stckchck Ltd operates.

 “Stocksee” is a mobile phone app that allows users to locate products stocked by physical retailers in their immediate area. The application, its architecture, all associated intellectual property and data is owned solely by stckchck Ltd (excluding personal data, which is of course owned by you!), company number: 11318256.

 If you have any questions or comments about this Privacy Policy, please contact us at queries@stocksee.co.uk

 2. What Personal Data do we collect/process and for which purposes?

 Stocksee collects no sensitive personal data relating to our users. We may process data about your use of Stocksee and services ("usage data"). The usage data may include your Stocksee app version, phone make and model, phone operating system, length of visit, location, page views and app navigation paths, as well as information about the timing, frequency and pattern of your service use. Your birth year, gender, email address (provided to us by you at time of registration) and user identification number will also be collected. The source of the usage data is our analytics tracking system. This usage data may be processed for the purposes of analysing the use of Stocksee and services, to operate, maintain, enhance and provide all features of the Service, to respond to comments and questions, and to provide support to users of the Service. The legal basis for this processing is consent OR our legitimate interests, namely monitoring and improving our app and services. The usage data may also be used to provide clients with information relating to the usage of stckchck by defined demographic groups.

 We may process your account data ("account data"). The account data may include your email address, gender and birth year. The account data may be processed for the purposes of operating our app, providing our services, ensuring the security of our app and services, maintaining back-ups of our databases and communicating with you. The legal basis for this processing is consent OR our legitimate interests, namely the proper administration of stckchck Ltd and business.

 We may process your personal data that are provided in the course of the use of our services ("service data”). The service data may be processed for the purposes of operating our app, providing our services, ensuring the security of our app and services, maintaining back-ups of our databases and communicating with you. The legal basis for this processing is consent OR our legitimate interests, namely the proper administration of Stocksee and business OR the performance of a contract between you and us and/or taking steps, at you request, to enter into such a contract.

 We may process information contained in any enquiry you submit to us regarding products and/or services ("enquiry data"). The enquiry data may be processed for the purposes of offering, marketing and selling relevant products and/or services to you. The legal basis for this processing consent OR our legitimate interests, namely the proper administration of Stocksee and business OR the performance of a contract between you and us and/or taking steps, at you request, to enter into such a contract.

 We may process information that you provide to us for the purpose of subscribing to our push notifications and/or email notifications/newsletters ("notification data"). The notification data may be processed for the purposes of sending you the relevant notifications and/or newsletters. The legal basis for this processing is consent OR our legitimate interests, namely the proper administration of Stocksee and business OR the performance of a contract between you and us and/or taking steps, at you request, to enter into such a contract.

 We may process information contained in or relating to any communication that you send to us ("correspondence data"). The correspondence data may include the communication content and metadata associated with the communication. The correspondence data may be processed for the purposes of communicating with you and record-keeping. The legal basis for this processing is our legitimate interests, namely the proper administration of Stocksee and business and communications with users.

 3. Who do we allow access to your data?

 We may disclose your personal data to any member of our group of companies (this means our subsidiaries, our ultimate holding company and all its subsidiaries) insofar as reasonably necessary for the purposes set out in this policy.

 4. How long is your data retained for, and how can you delete it?

 Personal data that we process for any purpose or purposes shall not be retained for longer than the lifetime of the users account, or otherwise for a limited period of time as long as long as we need it to fulfil the purposes for which we have initially collected it, unless otherwise required by law. We will retain and use information as necessary to comply with our legal obligations, resolve disputes, and enforce our agreements as follows: the contents of closed accounts are deleted within 3 months of the date of closure and backups are kept for 3 months. We will delete your personal data as follows:
 User account data will be deleted immediately upon request by the account holder. To delete your account, please email queries@stckchck.com and state your email address associated with the account, as well as your birth year.

 5. How is your data stored and processed?

 Your information collected through Stocksee may be stored and processed in Europe, the United States, or any other country in which stckchck or its subsidiaries, affiliates, or service providers maintain facilities. stckchck may transfer information that we collect about you to affiliated entities, or to third parties across borders from your country or jurisdiction to other countries or jurisdictions around the world.

 6. How is your data secured?

 User personal data is stored on servers provided by Firebase, a platform owned by Google. For detailed information relating to how Firebase secures data stored on its servers, please visit: https://firebase.google.com/support/privacy/

 Given that user data is collected and analysed using the Google Analytics tools suite, Google acts as a data processor. Firebase services encrypt data in transit using HTTPS and logically isolate customer data. In addition, the Firebase services used for the Stocksee application also encrypt their data at rest. Firebase employs extensive security measures to minimise access to the data stored by stckchck Ltd. This includes restricting access to select employees who have a business purpose to access personal data, Firebase logs employee access to systems that contain personal data, and Firebase only permits access to personal data by employees who sign in with Google Sign-In and 2-factor authentication.

 7. What are your rights?

 Your principal rights under data protection law are:
 (a) the right to access;
 (b) the right to rectification;
 (c) the right to erasure;
 (d) the right to restrict processing;
 (e) the right to object to processing;
 (f) the right to data portability;
 (g) the right to complain to a supervisory authority; and
 (h) the right to withdraw consent.

 You have the right to confirmation as to whether or not we process your personal data and, where we do, access to the personal data, together with certain additional information. That additional information includes details of the purposes of the processing, the categories of personal data concerned and the recipients of the personal data. Providing the rights and freedoms of others are not affected, we will supply to you a copy of your personal data. The first copy will be provided free of charge, but additional copies may be subject to a reasonable fee.

 You have the right to have any inaccurate personal data about you rectified and, taking into account the purposes of the processing, to have any incomplete personal data about you completed.

 In some circumstances you have the right to the erasure of your personal data without undue delay. Those circumstances include: the personal data are no longer necessary in relation to the purposes for which they were collected or otherwise processed; you withdraw consent to consent-based processing; the processing is for direct marketing purposes; and the personal data have been unlawfully processed. However, there are certain general exclusions of the right to erasure. Those general exclusions include where processing is necessary: for exercising the right of freedom of expression and information; for compliance with a legal obligation; or for the establishment, exercise or defence of legal claims.

 In some circumstances you have the right to restrict the processing of your personal data. Those circumstances are: you contest the accuracy of the personal data; processing is unlawful but you oppose erasure; we no longer need the personal data for the purposes of our processing, but you require personal data for the establishment, exercise or defence of legal claims; and you have objected to processing, pending the verification of that objection. Where processing has been restricted on this basis, we may continue to store your personal data. However, we will only otherwise process it: with your consent; for the establishment, exercise or defence of legal claims; for the protection of the rights of another natural or legal person; or for reasons of important public interest.

 You have the right to object to our processing of your personal data on grounds relating to your particular situation, but only to the extent that the legal basis for the processing is that the processing is necessary for: the performance of a task carried out in the public interest or in the exercise of any official authority vested in us; or the purposes of the legitimate interests pursued by us or by a third party. If you make such an objection, we will cease to process the personal information unless we can demonstrate compelling legitimate grounds for the processing which override your interests, rights and freedoms, or the processing is for the establishment, exercise or defence of legal claims.
 You have the right to object to our processing of your personal data for direct marketing purposes (including profiling for direct marketing purposes). If you make such an objection, we will cease to process your personal data for this purpose.

 You have the right to object to our processing of your personal data for scientific or historical research purposes or statistical purposes on grounds relating to your particular situation, unless the processing is necessary for the performance of a task carried out for reasons of public interest.

 To the extent that the legal basis for our processing of your personal data is consent, and such processing is carried out by automated means, you have the right to receive your personal data from us in a structured, commonly used and machine-readable format. However, this right does not apply where it would adversely affect the rights and freedoms of others.

 If you consider that our processing of your personal information infringes data protection laws, you have a legal right to lodge a complaint with a supervisory authority responsible for data protection. You may do so in the EU member state of your habitual residence, your place of work or the place of the alleged infringement.

 To the extent that the legal basis for our processing of your personal information is consent, you have the right to withdraw that consent at any time. Withdrawal will not affect the lawfulness of processing before the withdrawal.

 You may exercise any of your rights in relation to your personal data by written notice to us.

 8. How can you contact us?

 We welcome your feedback and if you have any questions regarding our privacy policy of the use of your information, please email queries@stckchck.com.
 stckchck Ltd has a Data Protection Officer (DPO) who is responsible for matters relating to privacy and data protection. Please contact our DPO using the following details:
 stckchck Ltd
 Attn: Data Protection Officer
 20-22 Wenlock Road
 London
 N1 7GU
 queries@stocksee.co.uk

 """
        
        return text
    }
    
}
