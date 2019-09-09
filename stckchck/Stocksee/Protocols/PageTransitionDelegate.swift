//
//  PageTransitionDelegate.swift
//  stckchck
//
//  Created by Pho on 12/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation

protocol PageTransitionDelegate: class {
    
    func pageController(onboardingPageVC: OnboardingPageViewController, didUpdatePageCount count: Int)
    
    func pageController(onboardingPageVC: OnboardingPageViewController, didUpdatePageIndex index: Int)
    
}
