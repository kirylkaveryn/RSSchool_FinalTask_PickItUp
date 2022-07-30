//
//  DumpModel.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 24.10.21.
//

import Foundation
import MapKit
import Firebase
import Contacts

enum GarbageType: String, CaseIterable {
    case mixed = "Mixed"
    case plastic = "Plastic"
    case metal = "Metal"
    case paper = "Paper"
    
    var settings: (color: UIColor, image: UIImage?) {
        switch self {
        case .plastic:
            return (.rsDumpPlasticColor, UIImage(named: "plastic"))
        case .metal:
            return (.rsDumpMetalColor, UIImage(named: "metal"))
        case .paper:
            return (.rsDumpPaperColor, UIImage(named: "paper"))
        case .mixed:
            return (.rsDumpMixedColor, UIImage(named: "mixed"))
        }
        
    }
}

enum DumpSize: String, CaseIterable {
    case small = "Small"
    case middle = "Middle"
    case big = "Big"
    case huge = "Huge"
    case disaster = "Disaster"
    case undefined = "Undefined"
}


struct DumpModelStorage {
    static var dumps: [DumpModel] = []
}


class DumpModel: NSObject, MKAnnotation {
    let id: String
    let userID: String
    var title: String?
    var locationName: String?
    var type: GarbageType
    var size: DumpSize
    var dumpImagesReference: [String:String]
    var dumpClearedImagesReference: [String:String]?
    var coordinate: CLLocationCoordinate2D
    var date: Date
    var clear: Bool
    
    var dumpImages: [String:UIImage]
    var dumpClearedImages: [String:UIImage]
    
    var mapItem: MKMapItem? {
        guard let location = locationName else { return nil }
        
        let addressDict = [CNPostalAddressStreetKey: location]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    
    init(userID: String, title: String?, locationName: String?, garbageType: GarbageType, dumpSize: DumpSize, coordinate: CLLocationCoordinate2D, date: Date) {
        let id = UUID().uuidString
        self.id = id
        self.userID = userID
        self.title = title
        self.locationName = locationName
        self.type = garbageType
        self.size = dumpSize
        self.coordinate = coordinate
        self.date = date
        self.clear = false
        self.dumpImagesReference = [:]
        self.dumpClearedImagesReference = [:]
        
        self.dumpImages = [:]
        self.dumpClearedImages = [:]
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let userID = value["userID"] as? String,
            let title = value["title"] as? String,
            let locationName = value["locationName"] as? String,
            let type = value["type"] as? String,
            let size = value["size"] as? String,
            let dumpImagesReference = value["dumpImagesReference"] as? [String:String],
            let coordinateLatitude = value["coordinateLatitude"] as? String,
            let coordinateLongtitude = value["coordinateLongtitude"] as? String,
            let latitude = Double(coordinateLatitude),
            let longtitude = Double(coordinateLongtitude),
            let date = value["date"] as? String,
            let clear = value["clear"] as? Bool
        else {
            return nil
        }
        
        if let value = snapshot.value as? [String: AnyObject] {
            if let dumpClearedImagesReference = value["dumpClearedImagesReference"] as? [String:String] {
                self.dumpClearedImagesReference = dumpClearedImagesReference
            } else {
                self.dumpClearedImagesReference = [:]
            }
        }
        
        
        self.id = id
        self.userID = userID
        self.title = title
        self.locationName = locationName
        self.type = GarbageType.init(rawValue: type) ?? GarbageType.mixed
        self.size = DumpSize.init(rawValue: size) ?? DumpSize.small
        self.dumpImagesReference = dumpImagesReference
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        self.date = getDateFromString(string: date)
        self.clear = clear
        
        self.dumpImages = [:]
        self.dumpClearedImages = [:]
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "userID": userID,
            "title": title ?? "",
            "locationName": locationName ?? "",
            "type": type.rawValue,
            "size": size.rawValue,
            "coordinateLongtitude": coordinate.longitude.description,
            "coordinateLatitude": coordinate.latitude.description,
            "date": date.description,
            "dumpImagesReference": dumpImagesReference,
            "dumpClearedImagesReference": dumpClearedImagesReference ?? ["":""],
            "clear" : clear
        ]
    }
    
    static func getDumpCoordinateString(coordinate: CLLocationCoordinate2D) -> String {
        let latitude = NSNumber.init(value: coordinate.latitude)
        let longitude = NSNumber.init(value: coordinate.longitude)
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 4
        numberFormatter.maximumFractionDigits = 7
        
        if let latitudeString = numberFormatter.string(from: latitude),
           let longitudeString = numberFormatter.string(from: longitude) {
            return latitudeString + ", " + longitudeString
        } else {
            return "..."
        }
    }
    
    static func getDumpSizeString(dump: DumpModel) -> String {
        return "Size: \(dump.size.rawValue)"
    }
    
    static func getDumpTypeString(dump: DumpModel) -> String {
        return "Garbage type: \(dump.type.rawValue)"
    }
    
    static func getDumpDateString(dump: DumpModel) -> String {
        return "Date: \(getStringFromDate(date: dump.date))"
    }
    
}
