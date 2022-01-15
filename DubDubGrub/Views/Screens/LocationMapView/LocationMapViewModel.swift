//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import Foundation
import MapKit
import CloudKit
import SwiftUI

extension LocationMapView {

    //Any UI update that happens in class will be routed to main thread
    @MainActor final class LocationMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

        @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
        @Published var isShowingDetailView = false
        @Published var alertItem: AlertItem?
        @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let deviceLocationManager = CLLocationManager()
        
        override init(){
            super.init()
            deviceLocationManager.delegate = self
        }
        
        func requestAllowOnceLocationPermission(){
            deviceLocationManager.requestLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let currentLocation = locations.last else {
                //No location or unable to get location
                return
            }
            withAnimation {
                region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed")
        }
        
        func getLocations(for locationManager: LocationManager){
            Task {
                do {
                    locationManager.locations = try await CloudKitManager.shared.getLocations()
                } catch {
                    alertItem = AlertContext.unableToGetLocations
                }
            }
//            CloudKitManager.shared.getLocations { [self] result in
//                //Update on main thread
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let locations):
//                        locationManager.locations = locations
//                    case .failure(_):
//                        alertItem = AlertContext.unableToGetLocations
//                    }
//                }
//            }
        }

        func getCheckedInLocationCount(){
            Task {
                do {
                    checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfilesCount()
                } catch {
                    alertItem = AlertContext.checkedInCount
                }
            }

        }

        //ViewBuilder allows ability to return any time of view
        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in dynamicTypeSize: DynamicTypeSize) -> some View {
            if dynamicTypeSize >= .accessibility3 {
                //Returns gemotery reader
                LocationDetailView(viewModel: LocationDetailView.LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                //Returns LocationDetailView
                LocationDetailView(viewModel: LocationDetailView.LocationDetailViewModel(location: location))
            }
        }
    }
}
