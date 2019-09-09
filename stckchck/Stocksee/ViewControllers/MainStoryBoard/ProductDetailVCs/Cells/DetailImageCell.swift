//
//  DetailImageCell.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class DetailImageCell: UICollectionViewCell, ListBindable {
    
    @IBOutlet var productImageView: UIImageView!
    
    var pageCount = 0
    
    //This scroll view will hold the stackView that will hold the array of imageviews
    lazy fileprivate var scrollView: UIScrollView = {
    
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        self.contentView.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        //Constraints... Do we need these?pin scrollView 20-pts from top/bottom/leading/trailing
        scrollView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    //Stack view that will hold the image view
    lazy fileprivate var stackView: UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        //Constraints... Do we need these?
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        
        return stackView
        
    }()
    
    lazy fileprivate var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(red: 0.73, green: 0.83, blue: 0.94, alpha: 1.0)
        pageControl.currentPageIndicatorTintColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
        pageControl.frame = CGRect()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageControl)
        contentView.bringSubview(toFront: pageControl)
        
        //Constraints
        pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        pageControl.numberOfPages = 5
        return pageControl
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = contentView.bounds
        scrollView.frame = bounds
    
    }
    
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? DetailImageVM else {
            print("deadBeef IGLK failed to make dImageVM")
            return
        }
        
        scrollView.delegate = self
        
        let imageURLs = viewModel.imageURLs
        let numberOfImages = imageURLs.count
        print("deadBeef numberOfImages: \(numberOfImages)")
        
        scrollView.contentSize.width = scrollView.bounds.width * CGFloat(numberOfImages)
        pageControl.numberOfPages = numberOfImages
        
        var numberOfIVs = 0
        
        for url in imageURLs {
            
            guard numberOfIVs <= numberOfImages else {
                print("deadBeef too many IVs made, aborting")
                return
            }
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
            imageView.frame = scrollView.bounds
            numberOfIVs += 1
            
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1).isActive = true
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
            
            
            imageView.loadImageFrom(url: url) { (success) in
                if success {
                    print("deadBeef IGLK loaded image for ProductDetail")
                } else if !success {
                    print("deadBeef IGLK failed to load image for ProductDetail")
                }
            }
        }
    }
}

extension DetailImageCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / contentView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
    }
    
}
