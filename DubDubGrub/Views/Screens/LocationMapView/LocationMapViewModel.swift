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

final class LocationMapViewModel: ObservableObject {

    @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
    @Published var isShowingDetailView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                                       span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    func getLocations(for locationManager: LocationManager){
        CloudKitManager.shared.getLocations { [self] result in
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

    func getCheckedInLocationCount(){
        CloudKitManager.shared.getCheckedInProfilesCount { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let checkedInProfiles):
                        self.checkedInProfiles = checkedInProfiles
                    case .failure(_):
                        //show alert
                        break
                }
            }
        }
    }

    //ViewBuilder allows ability to return any time of view
    @ViewBuilder func createLocationDetailView(for location: DDGLocation, in sizeCategory: ContentSizeCategory) -> some View {
        if sizeCategory >= .accessibilityMedium {
            //Returns gemotery reader
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            //Returns LocationDetailView
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
}
