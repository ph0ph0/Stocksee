//
//  FacetModel.swift
//  stckchck
//
//  Created by Pho on 23/01/2019.
//  Copyright © 2019 stckchck. All rights reserved.
//

import Foundation

class Facet {
    
    //facetName is the name of the facet in the database, facetRepresentation is the name shown to the user
    var facetName: String?
    var facetRepresentation: String?
    var facetType: String!
    var productMetaData = ProductMetaData()
    
    init(facetName: String, facetRepresentation: String, facetType: String) {
        self.facetType = facetType
        
        self.facetName = facetName
        self.facetRepresentation = facetRepresentation
        self.facetRepresentation = formatFacetRepresentation(facet: facetRepresentation)
    }
    
    private func formatFacetRepresentation(facet: String) -> String {
        
        var formattedFacet = facet
        
        if formattedFacet == "Apparel" {
            formattedFacet = "Clothing"
        }
        if formattedFacet == "FaceMakeUp" {
            formattedFacet = "Makeup"
        }
        if formattedFacet == "Male" {
            formattedFacet = "Men's"
        }
        if formattedFacet == "Female" {
            formattedFacet = "Women's"
        }
        formattedFacet = formattedFacet.camelCaseToWords()
        formattedFacet = formattedFacet.replacingOccurrences(of: " And ", with: " and ")
        
        return formattedFacet
    }
}

extension Facet: Equatable, Comparable {
    static func == (lhs: Facet, rhs: Facet) -> Bool {
        return lhs.facetName == rhs.facetName
    }
    
    static func < (lhs: Facet, rhs: Facet) -> Bool {
        //We must use fR instead of fN as the fN for clothing is apparel, so will be sorted according to apparel!
        return lhs.facetRepresentation! < rhs.facetRepresentation!
    }
}
