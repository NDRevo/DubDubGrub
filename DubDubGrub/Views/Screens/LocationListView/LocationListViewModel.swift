//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/6/22.
//

import Foundation
import CloudKit

final class LocationViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [CKRecord.ID:[DDGProfile]] = [:]
    
    func getCheckedInProfileDictionary(){
        CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let checkInProfiles):
                        self.checkedInProfiles = checkInProfiles
                    case .failure(_):
                        print("ERROR getting back dictionary")
                }
            }
        }
    }
}
