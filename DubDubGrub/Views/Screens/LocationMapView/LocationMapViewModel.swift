//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import Foundation
import MapKit

final class LocationMapViewModel: ObservableObject {

    @Published var isShowingDetailView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516,
                                                                                      longitude: -121.891054),
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
}
