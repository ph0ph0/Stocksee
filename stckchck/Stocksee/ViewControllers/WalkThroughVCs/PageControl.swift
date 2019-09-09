//
//  PageControl.swift
//  stckchck
//
//  Created by Pho on 13/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import  UIKit

class PageControl: UIViewController, PageTransitionDelegate {
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let onboardingPageVC = segue.destination as? OnboardingPageViewController {
            onboardingPageVC.pageTransitionDelegate = self
        }
    }
    
    func pageController(onboardingPageVC: OnboardingPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func pageController(onboardingPageVC: OnboardingPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
    
}
