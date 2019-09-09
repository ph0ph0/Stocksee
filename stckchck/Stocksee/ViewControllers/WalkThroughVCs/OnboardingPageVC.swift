//
//  OnboardingPageVC.swift
//  stckchck
//
//  Created by Pho on 11/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    private (set) lazy var orderedViewControllers: [UIViewController] = {
        return [getStepOne(), getStepTwo(), getStepThree(), getStepFour()]
    }()
    
    weak var pageTransitionDelegate: PageTransitionDelegate?
    
    func getStepOne() -> StepOneViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepOneViewController") as! StepOneViewController
    }
    
    func getStepTwo() -> StepTwoViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepTwoViewController") as! StepTwoViewController
    }
    
    func getStepThree() -> StepThreeViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepThreeViewController") as! StepThreeViewController
    }
    
    func getStepFour() -> StepFourViewController {
        return storyboard!.instantiateViewController(withIdentifier: "StepFourViewController") as! StepFourViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        pageTransitionDelegate?.pageController(onboardingPageVC: self, didUpdatePageCount: orderedViewControllers.count)
        
        dataSource = self
        delegate = self
        
        view.backgroundColor = .clear
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let vCCount = orderedViewControllers.count
        
        guard nextIndex != vCCount else {
            return nil
        }
        
        guard nextIndex < vCCount else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex - 1
        let vCCount = orderedViewControllers.count
        
        guard nextIndex < vCCount else {
            return nil
        }
        
        guard nextIndex >= 0 else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
        
    }
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstVC = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstVC) {
            
            pageTransitionDelegate?.pageController(onboardingPageVC: self, didUpdatePageIndex: index)
            
        }
    }
}
