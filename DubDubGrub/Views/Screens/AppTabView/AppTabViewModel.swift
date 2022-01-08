//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/6/22.
//

import Foundation
import CoreLocation

//NSObject for CLLocationManagerDelegate
final class AppTabViewModel: NSObject, ObservableObject{
    @Published var isShowingOnboardView = false
    @Published var alertItem: AlertItem?

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
            
            //Force unwrap because we know it exists based on line 36
            deviceLocationManager!.delegate = self
            
            //checkLocationAuthorization() Redundant as delegate already calls this when creating a new CLLocationManager
            deviceLocationManager!.desiredAccuracy = kCLLocationAccuracyBest
            
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
}

extension AppTabViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
