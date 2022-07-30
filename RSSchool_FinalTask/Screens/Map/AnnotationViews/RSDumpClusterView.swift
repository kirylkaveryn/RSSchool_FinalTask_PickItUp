//
//  RSDumpClusterView.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 14.11.21.
//

import Foundation
import MapKit

class RSDumpClusterView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: 00)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            if let cluster = newValue as? MKClusterAnnotation {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
                let count = cluster.memberAnnotations.count
                
                image = renderer.image { _ in
                    // Fill full circle
                    UIColor.rsRedMain.setFill()
                    UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
                    
                    // Fill all sectors
                    for type in GarbageType.allCases {
                        type.settings.color.setFill()
                        let piePath = UIBezierPath()
                        
                        let typeCount = cluster.memberAnnotations.filter { annotation -> Bool in
                            return (annotation as! DumpModel).type == type
                        }.count
                        
                        piePath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                                       startAngle: 0, endAngle: (CGFloat.pi * 2.0 * CGFloat(typeCount)) / CGFloat(count), clockwise: true)
                        piePath.addLine(to: CGPoint(x: 20, y: 20))
                        piePath.close()
                        piePath.fill()
                    }
                    
                    // Fill inner circle with white color
                    UIColor.white.setFill()
                    UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()
                    
                    // Add label
                    let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                       NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
                    let text = "\(count)"
                    let size = text.size(withAttributes: attributes)
                    let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
                    text.draw(in: rect, withAttributes: attributes)
                }
            }
        }
    }

}
