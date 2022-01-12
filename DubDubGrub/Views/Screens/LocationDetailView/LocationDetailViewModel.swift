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

    @MainActor final class LocationDetailViewModel: ObservableObject {

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
        
        func determineColumns(for dynamicTypeSize: DynamicTypeSize) -> [GridItem]{
            let numberOfColumns = dynamicTypeSize >= .accessibility3 ? 1 : 3
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
            
            Task{
                do{
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference{
                        isCheckedIn = reference.recordID == location.id
                    } else {
                        isCheckedIn = false
                    }
                } catch {
                    alertItem = AlertContext.unableToGetCheckInStatus
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
            
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    switch checkInStatus {
                        case .checkedIn:
                            record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                            record[DDGProfile.kIsCheckedInNilChecked] = 1
                        case .checkedOut:
                            record[DDGProfile.kIsCheckedIn] = nil
                            record[DDGProfile.kIsCheckedInNilChecked] = 0
                    }
                    
                    let savedRecord = try await CloudKitManager.shared.save(record: record)
                    let profile = DDGProfile(record: savedRecord)
                    HapticManager.playHaptic(with: .success)
                    switch checkInStatus {
                        case .checkedIn:
                            checkedInProfiles.append(profile)
                        case .checkedOut:
                            checkedInProfiles.removeAll(where: {$0.id == profile.id})
                    }
                    isCheckedIn.toggle()
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToCheckInOrOut
                }
            }
        }
        
        func getCheckedInProfiles(){
            showLoadingView()
            Task{
                do {
                    checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfiles(for: location.id)
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToGetCheckedInProfiles
                    
                }
            }
        }
        
        func show(_ profile: DDGProfile, in dynamicTypeSize: DynamicTypeSize){
            selectedProfile = profile
            if dynamicTypeSize >= .accessibility3 {
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
