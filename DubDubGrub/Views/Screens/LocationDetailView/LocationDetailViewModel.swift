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

extension LocationDetailView {

    final class LocationDetailViewModel: ObservableObject {

        var location: DDGLocation
        var selectedProfile: DDGProfile?
        var buttonColor: Color {
            isCheckedIn ? .grubRed : .brandPrimary
        }
        var buttonImageTitle: String {
            isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark"
        }
        var buttonA11yLabel: String {
            isCheckedIn ? "Check out of location" : "Check into location"
        }

    //    let columns = [GridItem(.flexible()),
    //                   GridItem(.flexible()),
    //                   GridItem(.flexible())]

        @Published var isLoading = false
        @Published var checkedInProfiles: [DDGProfile] = []
        @Published var isShowingProfileModal = false
        @Published var isShowingSheet        = false
        @Published var isCheckedIn           = false
        @Published var alertItem: AlertItem?


        init(location: DDGLocation){
            self.location = location
        }
        
        func determineColumns(for sizeCategory: ContentSizeCategory) -> [GridItem]{
            let numberOfColumns = sizeCategory >= .accessibilityMedium ? 1 : 3
            return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
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
        
        func getCheckedInStatus(){
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let record):
                            if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference{
                                isCheckedIn = reference.recordID == location.id
                            } else {
                                isCheckedIn = false
                            }
                        case .failure(_):
                            //Cant change status
                            alertItem = AlertContext.unableToGetCheckInStatus
                    }
                }
            }
        }
        
        func updateCheckInStatus(to checkInStatus: CheckInStatus){
            //Retrieve DDGProfile
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.unableToGetProfile
                return
            }
            showLoadingView()
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
                switch result {
                case .success(let record):
                    //Create reference to location
                    switch checkInStatus {
                        case .checkedIn:
                            record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                            record[DDGProfile.kIsCheckedInNilChecked] = 1
                        case .checkedOut:
                            record[DDGProfile.kIsCheckedIn] = nil
                            record[DDGProfile.kIsCheckedInNilChecked] = 0
                    }
                    //Save updated profile to cloudkit
                    CloudKitManager.shared.save(record: record) { result in
                        DispatchQueue.main.async {
                            hideLoadingView()
                            switch result {
                                case .success(_):
                                    //update our checkedInProfiles array
                                    let profile = DDGProfile(record: record)
                                    HapticManager.playHaptic(with: .success)
                                    switch checkInStatus {
                                        case .checkedIn:
                                            checkedInProfiles.append(profile)
                                        case .checkedOut:
                                            checkedInProfiles.removeAll(where: {$0.id == profile.id})
                                    }
                                    
                                    isCheckedIn.toggle()
                                case .failure(_):
                                    alertItem = AlertContext.unableToCheckInOrOut
                            }
                        }
                    }
                case .failure(_):
                    hideLoadingView()
                    alertItem = AlertContext.unableToCheckInOrOut
                }
            }
        }
        
        func getCheckedInProfiles(){
            showLoadingView()
            CloudKitManager.shared.getCheckedInProfiles(for: location.id) { [self] result in
                //Working with views (checkInProfile is Published var)
                DispatchQueue.main.async {
                    switch result {
                        case .success(let profiles):
                            checkedInProfiles = profiles
                        case .failure(_):
                            alertItem = AlertContext.unableToGetCheckedInProfiles
                    }
                    hideLoadingView()
                }
            }
        }
        
        func show(_ profile: DDGProfile, in sizeCategory: ContentSizeCategory){
            selectedProfile = profile
            if sizeCategory >= .accessibilityMedium {
                isShowingSheet = true
            } else {
                isShowingProfileModal = true
            }
        }

        private func showLoadingView(){
            isLoading = true
        }

        private func hideLoadingView(){
            isLoading = false
        }
    }
}
