//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/6/22.
//

import Foundation
import CloudKit
import SwiftUI

extension LocationListView {
    @MainActor final class LocationViewModel: ObservableObject {
        
        @Published var checkedInProfiles: [CKRecord.ID:[DDGProfile]] = [:]
        @Published var alertItem: AlertItem?
        
        func getCheckedInProfileDictionary() async{
            do {
                checkedInProfiles = try await CloudKitManager.shared.getCheckedInProfilesDictionary()
                print("Called")
            } catch {
                alertItem = AlertContext.unableToGetAllCheckedInProfiles
            }
        }
        
        func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: []].count
            let personPlurality = count == 1 ? "person" : "people"
            
            return "\(location.name) \(count) \(personPlurality) checked in."
        }
        
        //ViewBuilder allows ability to return any time of view for accessibility
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
