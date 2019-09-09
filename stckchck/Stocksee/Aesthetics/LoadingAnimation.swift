//
//  LoadingAnimation.swift
//  stckchck
//
//  Created by Pho on 14/09/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class LoadingAnimation: UIView {
    
    private let loadingAnimation = LOTAnimationView(name: "LoadingAnimation")
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        loadingAnimation.frame = self.bounds
    }
    
    fileprivate func configureView() {
        self.frame = CGRect(x: UIScreen.main.bounds.midX - 90, y: (UIScreen.main.bounds.midY - 90) - 80, width: 180, height: 180)
        self.backgroundColor = .clear
        self.alpha = 0
        loadingAnimation.contentMode = .scaleAspectFill
        loadingAnimation.animationSpeed = 1.0
        loadingAnimation.loopAnimation = true
        addSubview(loadingAnimation)
    }
    
    func display() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.loadingAnimation.play(fromFrame: 1, toFrame: 40, withCompletion: nil)
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.alpha = 1.0
            }
        }
    }
    
    func stop() {
        DispatchQueue.main.async { [weak weakSelf = self] in
            weakSelf?.loadingAnimation.stop()
            weakSelf?.removeFromSuperview()
        }
        
    }
}





