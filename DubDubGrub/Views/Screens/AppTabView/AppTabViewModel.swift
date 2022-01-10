//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/6/22.
//

import Foundation
import CoreLocation
import SwiftUI

//NSObject for CLLocationManagerDelegate

extension AppTabView {
    final class AppTabViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
        @Published var isShowingOnboardView = false
        @Published var alertItem: AlertItem?
        @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
            didSet {
                isShowingOnboardView = hasSeenOnboardView
            }
        }

        //Optional because user can turn off location services
        var deviceLocationManager: CLLocationManager?
        let kHasSeenOnboardView: String = "hasSeenOnboardView"
        
        func runStartupChecks(){
            if !hasSeenOnboardView {
                hasSeenOnboardView = true
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
            guard let deviceLocationManager = deviceLocationManager else { return }

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

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkLocationAuthorization()
        }
    }
}
