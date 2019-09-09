//
//  FacetSearcher.swift
//  stckchck
//
//  Created by Pho on 22/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation
import AlgoliaSearch

struct ProductMetaData {
    let Category = "Meta.Category"
    let SubCategory = "Meta.SubCategory"
    let SubSubCategory = "Meta.SubSubCategory"
    let Sex = "Meta.Sex"
}

class FacetSearcher {
    
    var index: Index!
    typealias facetClosure = ([Facet]) -> ()
    var filter = ""
    
    //We are trying to find the appropriate Meta values in a cross-section of products. The cross section is defined by the `filters` and then we look within the Meta attribute of these to find the Category/Sex/SubCategory/SubSubCategory values.
    
    func findFacets(in Meta: String, using filterStringData: (String, Bool), completionHandler completion: @escaping facetClosure) {
        
        var facets = [Facet]()
        
        let didReachEndOfMetaLevels = filterStringData.1
        
        guard !didReachEndOfMetaLevels else {
            completion(facets)
            return
        }

        
        let index = AlgoliaManager.sharedInstance.productsIndex
        let query = Query()
        query.query = ""
        query.filters = filterStringData.0
        
        index.searchForFacetValues(of: Meta, matching: "", query: query, requestOptions: nil) { (result, error) in
            print("deadBeef searching facetValues...")
            
            if error == nil {
                
                guard let jsonData = result else {
                    print("deadBeef no result from facet search")
                    return
                }
                
                guard let jsonHits = jsonData["facetHits"] as! [Any]? else {
                    print("deadBeef no jsonHits")
                    return
                }
                
                for hit in jsonHits {
                    let jsonHit = hit as! [String: Any]
                    let facetName = jsonHit["value"] as! String
                    let facetRepresentation = facetName
                    let facet = Facet(facetName: facetName, facetRepresentation: facetRepresentation, facetType: Meta)
                    facets.append(facet)
                }
                
                print("!!!facets: \(facets)")
                
                completion(facets)
                
            } else {
                print("deadBeef error: \(String(describing: error))")
            }
        }
        
    }
    
}
