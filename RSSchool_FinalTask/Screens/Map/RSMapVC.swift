//
//  RSMapVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 24.10.21.
//

import UIKit
import MapKit
import CoreLocation

class RSMapVC: UIViewController, RSMapViewModelViewDelegate {

    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var currentUserLocationButton: RSMapButton!
    @IBOutlet weak var zoomInButton: RSMapButton!
    @IBOutlet weak var zoomOutButton: RSMapButton!
    @IBOutlet weak var mapSettingsButton: RSMapButton!
    
    var viewModel: RSMapViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    let locationManager = CLLocationManager()
    var currentAnnotationView = MKAnnotationView()
    var currentRegionMeters: Double = 10000
    var defaultRegionMeters: Double = 1000
    var deltaSpan: Double = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()        
        navigationController?.setNavigationBarHidden(true, animated: true)

        currentUserLocationButton.configureButton(radius: 22.5, image: RSDefaultIcons.location)
        zoomInButton.configureButton(radius: 22.5, image: RSDefaultIcons.plus)
        zoomOutButton.configureButton(radius: 22.5, image: RSDefaultIcons.minus)
        mapSettingsButton.configureButton(radius: 22.5, image: RSDefaultIcons.settings)
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
        mapView.register(RSDumpMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(RSDumpClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        setupMapSettingsButton()
        viewModel.getAllDumps()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        checkLocationServices()
        viewModel.startObservingData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.finishObservingData()
    }
    
    func checkLocationServices() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                disableLocationTracking()
                // show alert instructions whats happened
                break
            case .denied:
                disableLocationTracking()
                // show alert instructions how to enable
                break
            case .authorizedAlways:
                enableLocationTracking()
                break
            case .authorizedWhenInUse:
                enableLocationTracking()
                break
            @unknown default:
                locationManager.requestWhenInUseAuthorization()
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func enableLocationTracking() {
        currentUserLocationButton.isEnabled = true
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        centerViewOnUserLocation()
        CurrentUserLocation.coordinates = mapView.userLocation.coordinate
    }
    
    func disableLocationTracking() {
        currentUserLocationButton.isEnabled = false
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            locationManager.stopUpdatingLocation()

            let region = MKCoordinateRegion(center: location, latitudinalMeters: defaultRegionMeters, longitudinalMeters: defaultRegionMeters)
            mapView.setRegion(region, animated: true)
            currentRegionMeters = defaultRegionMeters
            currentUserLocationButton.imageView?.tintColor = .rsGreenMain
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupMapSettingsButton() {
        let standart = UIAction(title: "Vector") { [unowned self] action in
            self.mapView.mapType = .standard
        }
        let hybird = UIAction(title: "Hybird") { [unowned self] action in
            self.mapView.mapType = .hybrid
        }
        let satellite = UIAction(title: "Satellite") { [unowned self] action in
            self.mapView.mapType = .satellite
        }
        let menu = UIMenu(title: "Settings", options: .displayInline, children: [standart, hybird, satellite])
        mapSettingsButton.menu = menu
        mapSettingsButton.showsMenuAsPrimaryAction = true
    }
    
    
    // MARK: IBActions
    @IBAction func currentUserLocationButtonDidPress(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    @IBAction func zoomInButtonDidPress(_ sender: Any) {
        let newSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * deltaSpan, longitudeDelta: mapView.region.span.longitudeDelta * deltaSpan)
        let region = MKCoordinateRegion(center: mapView.region.center, span: newSpan)
            mapView.setRegion(region, animated: true)
    }
    @IBAction func zoomOutButtonDidPress(_ sender: Any) {
        
        let newSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * (1 / deltaSpan), longitudeDelta: mapView.region.span.longitudeDelta * (1 / deltaSpan))
        let region = MKCoordinateRegion(center: mapView.region.center, span: newSpan)
            mapView.setRegion(region, animated: true)
    }
    @IBAction func mapSettingsButtonDidPress(_ sender: Any) {
        
    }
    
}

// MARK: RSMapViewModelViewDelegate actions
extension RSMapVC {
    func updateScreen() {
        for dump in viewModel.activeDumps {
            if !mapView.annotations.contains(where: { annotation in
                guard let dumpAnnotation = annotation as? DumpModel else { return false }
                if dumpAnnotation.id == dump.id {
                }
                return dumpAnnotation.id == dump.id
            }) {
                mapView.addAnnotation(dump)
            }
        }
    }
    
    func removeDump(dump: DumpModel?) {
        mapView.annotations.forEach({ [weak self] annotation in
            guard let dumpAnnotation = annotation as? DumpModel else { return }
            if dumpAnnotation.id == dump?.id {
                self?.mapView.removeAnnotation(dumpAnnotation)
            }
        })
    }
    
    func deselectAnnotaionView() {
        mapView.deselectAnnotation(currentAnnotationView.annotation, animated: true)
    }
}


// MARK: MKMapViewDelegate
extension RSMapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? DumpModel else { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        if view == nil {
            view = RSDumpMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        } else {
            view?.annotation = annotation
        }

        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let dump = view.annotation as? DumpModel else { return }
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        dump.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let clusterView = view as? RSDumpClusterView {
            guard let viewCenter = clusterView.annotation?.coordinate else { return }
            let newSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * deltaSpan, longitudeDelta: mapView.region.span.longitudeDelta * deltaSpan)
            let newRegion = MKCoordinateRegion(center: viewCenter, span: newSpan)
            mapView.setRegion(newRegion, animated: true)
        }

        if let dump = view.annotation as? DumpModel {
            currentAnnotationView = view
            
            let dumpCenter = mapView.convert(dump.coordinate, toPointTo: self.view)
            let mapCenter = mapView.convert(mapView.region.center, toPointTo: self.view)

            if dumpCenter.y > mapCenter.y - 50 {
                let newDumpCenter = CGPoint(x: mapCenter.x, y: dumpCenter.y + mapCenter.y / 3)
                let newDumpCenterCoordinates = mapView.convert(newDumpCenter, toCoordinateFrom: self.view)
                let newRegion = MKCoordinateRegion(center: newDumpCenterCoordinates, span: mapView.region.span)
                mapView.setRegion(newRegion, animated: true)
            }
            viewModel.dumpDidSelect(dump: dump)
        }
     
    }
    
}

// MARK: CLLocationManagerDelegate
extension RSMapVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: currentRegionMeters, longitudinalMeters: currentRegionMeters)
        mapView.setRegion(region, animated: true)
        CurrentUserLocation.coordinates = center
    }

}
