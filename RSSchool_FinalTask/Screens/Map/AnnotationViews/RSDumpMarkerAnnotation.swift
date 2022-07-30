//
//  RSDumpMarkerAnnotationView.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 4.11.21.
//

import UIKit
import MapKit

class RSDumpMarkerAnnotationView: MKMarkerAnnotationView {
    
    static var reuseID = "RSDumpMarkerAnnotationView"
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let dump = newValue as? DumpModel else { return }
            
            canShowCallout = false
            titleVisibility = .hidden
            glyphTintColor = .white.withAlphaComponent(0.75)
            
            markerTintColor = dump.type.settings.color
            glyphImage = UIImage(systemName: "smallcircle.fill.circle.fill")
            selectedGlyphImage = dump.type.settings.image
            
            clusteringIdentifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        }
    }
    
}
