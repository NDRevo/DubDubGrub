//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/5/22.
//

import SwiftUI
import MapKit
import CloudKit

enum CheckInStatus {
    case checkedIn, checkedOut
}

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
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus){
        //Retrieve DDGProfile
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            //Alert
            return
        }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            case .success(let record):
                //Create reference to location
                switch checkInStatus {
                    case .checkedIn:
                        record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    case .checkedOut:
                        record[DDGProfile.kIsCheckedIn] = nil
                }
                //Save updated profile to cloudkit
                CloudKitManager.shared.save(record: record) { result in
                    switch result {
                        case .success(_):
                            //update our checkedInProfiles array
                            print("CHECKED IN/OUT SUCCESSFULLY")
                        case .failure(_):
                            print("Saved record FAILED")
                    }
                }
            case .failure(_):
                print("Error fetching record")
            }
        }
    }
}
