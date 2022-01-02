//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import Foundation
import MapKit

final class LocationMapViewModel: NSObject, ObservableObject {
    @Published var isShowingOnboardView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                                      longitude: -121.891054),
                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    //Optional because user can turn off location services
    var deviceLocationManager: CLLocationManager?
    
    let kHasSeenOnboardView: String = "hasSeenOnboardView"
    
    var hasSeenOboardView: Bool {
        return UserDefaults.standard.bool(forKey: kHasSeenOnboardView) //If no value, defaults to false
    }
    
    func runStartupChecks(){
        if !hasSeenOboardView {
            isShowingOnboardView = true
            UserDefaults.standard.set(true, forKey: kHasSeenOnboardView)
        } else {
            checkIfLocationServicesIsEnabled()
        }
    }
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled() {
            deviceLocationManager = CLLocationManager()
            
            //Force unwrap because we know it exists based on line 22
            deviceLocationManager!.delegate = self
            
            //checkLocationAuthorization() Redundant as delegate already calls this when creating a new CLLocationManager
            deviceLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
        } else {
            alertItem = AlertContext.locationsDenied
        }
    }
    
    private func checkLocationAuthorization(){
        guard let deviceLocationManager = deviceLocationManager else {
            return
        }

        switch deviceLocationManager.authorizationStatus{
            
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            alertItem = AlertContext.locationsRestricted
        case .denied:
            alertItem = AlertContext.locationsDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
    func getLocations(for locationManager: LocationManager){
        CloudKitManager.getLocations { [self] result in
            //Update on main thread
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    locationManager.locations = locations
                case .failure(_):
                    alertItem = AlertContext.unableToGetLocations
                }
            }
        }
    }
}

extension LocationMapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
