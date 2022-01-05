//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/5/22.
//

import Foundation
import SwiftUI
import MapKit

final class LocationDetailViewModel: ObservableObject {
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]

    var location: DDGLocation
    @Published var isShowingProfileModal = false
    @Published var alertItem: AlertItem?
    

    init(location: DDGLocation){
        self.location = location
    }
    
    func getDirectionsToLocation(){
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    func callLocation(){
        guard let url = URL(string: "tel://\(location.phoneNumber)") else {
            alertItem = AlertContext.invalidPhoneNumber
            return
        }
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
}
