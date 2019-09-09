//
//  Polyline.swift
//  stckchck
//
//  Created by Pho on 05/10/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import Mapbox

class Polyline {
    
    public var hasBeenDrawn = false
    private var polylineSource: MGLShapeSource?
    private var coordinates: [CLLocationCoordinate2D]?
    
    func addPolyline(to style: MGLStyle?, with coordinates: [CLLocationCoordinate2D]) {
        
        print("deadBeef pdVC drawing polyline")
        
        //MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = style else { return }
        
        if let currentSource = style.source(withIdentifier: "polyline") as? MGLShapeSource {
            style.removeSource(currentSource)
        }
        
        let polyline = MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
        
        let source = MGLShapeSource(identifier: "polyline", shape: polyline, options: nil)
        
        //We check if the polyline has been drawn yet. If it had and were to add the source, we would get a crash as the source would already exist.
        if !hasBeenDrawn {
            style.addSource(source)
            polylineSource = source
            self.coordinates = coordinates
        }
        
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        
        // Set the line join and cap to a rounded end.
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue: UIColor(red:0.45, green:0.63, blue:0.87, alpha:1.0))
        
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 2, 18: 20])
        
        // We can also add a second layer that will draw a stroke around the original line.
        let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
        
        // Copy these attributes from the main line layer.
        casingLayer.lineJoin = layer.lineJoin
        casingLayer.lineCap = layer.lineCap
        // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
        casingLayer.lineGapWidth = layer.lineWidth
        // Stroke color slightly darker than the line color.
        casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red:0.29, green:0.46, blue:0.89, alpha:1.0))
        // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
        casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                             [14: 1, 18: 4])
        
        // Just for fun, let’s add another copy of the line with a dash pattern.
        let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
        
        dashedLayer.lineJoin = layer.lineJoin
        dashedLayer.lineCap = layer.lineCap
        dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
        dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
        dashedLayer.lineWidth = layer.lineWidth
        // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
        
        //If the polyline has already been drawn, we remove all the layers as otherwise we would get a crash with layer already exists
        if hasBeenDrawn {
            let currentPolylineLayer = style.layer(withIdentifier: "polyline")
            let currentCaseLayer = style.layer(withIdentifier: "polyline-case")
            let currentDashLayer = style.layer(withIdentifier: "polyline-dash")
            style.removeLayer(currentPolylineLayer!)
            style.removeLayer(currentCaseLayer!)
            style.removeLayer(currentDashLayer!)
            print("deadBeef removed layers")
        }
        
        style.addLayer(layer)
        style.addLayer(dashedLayer)
        style.insertLayer(casingLayer, below: layer)
        
        hasBeenDrawn = true
    }
    
    func updatePolyline(with coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        //Updating the shape will redraw our polyline.
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        polylineSource?.shape = polyline
    }
    
}
