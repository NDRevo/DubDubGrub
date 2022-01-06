//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/5/22.
//

import Foundation
import CloudKit

enum ProfileContext {
    case create, update
}

final class ProfileViewModel: ObservableObject {

    @Published var firstName    = ""
    @Published var lastName     = ""
    @Published var companyName  = ""
    @Published var bio          = ""
    @Published var avatar       = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var isLoading    = false
    @Published var isCheckedIn    = false
    @Published var alertItem: AlertItem?
    
    //When value of existingProfileRecord changes, didSet is called to update context to .update
    private var existingProfileRecord: CKRecord? {
        didSet {
            profileContext = .update
        }
    }
    var profileContext: ProfileContext = .create
    
    func getCheckedInStatus(){
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let record):
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference{
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func checkOut(){
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.unableToGetProfile
            return
        }

        CloudKitManager.shared.fetchRecord(with: profileID) { result in
            switch result {
                case .success(let record):
                    //Checking Out
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilChecked] = 0
                    
                    CloudKitManager.shared.save(record: record) { [self] result in
                        DispatchQueue.main.async {
                            switch result {
                                case .success(_):
                                    isCheckedIn = false
                                case .failure(_):
                                    alertItem = AlertContext.unableToCheckInOrOut
                            }
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.alertItem = AlertContext.unableToCheckInOrOut
                    }
            }
        }
    }
    func isValidProfile() -> Bool{
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else {
                  return false
              }
        return true
    }

    func createProfile(){
        guard isValidProfile() else {
            alertItem = AlertContext.invalidProfile
            return
        }
        //Create CKRecord from profile view
        let profileRecord = createProfileRecord()
        
        guard let userRecord = CloudKitManager.shared.userRecord else {
            alertItem = AlertContext.noUserRecord
            return
        }

        //Create reference on UserRecord to DDGProfile we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)

        showLoadingView()
        CloudKitManager.shared.batchSave(records: [userRecord,profileRecord]) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(let records):
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        //Makes sure to update profileRecordID when first creating a profile
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    alertItem = AlertContext.createProfileSuccess
                    break
                case .failure(_):
                    alertItem = AlertContext.createProfileFailure
                    break
                }
            }
        }
    }

    func getProfile(){

        guard let userRecord = CloudKitManager.shared.userRecord else {
            alertItem = AlertContext.noUserRecord
            return
        }

        //Get reference, if none it means they havent created a profile
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else {
            return
        }

        let profileRecordID = profileReference.recordID
        showLoadingView()
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            //Working on background thread, need to be on main thread in order for views to be updated
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                    case .success(let record):
                        existingProfileRecord = record
                    
                        let profile = DDGProfile(record: record)
                        firstName   = profile.firstName
                        lastName    = profile.lastName
                        companyName = profile.companyName
                        bio         = profile.bio
                        avatar      = profile.createAvatarImage()
                    case .failure(_):
                        alertItem = AlertContext.unableToGetProfile
                        break
                    }
            }
        }
    }

    //Instead of creating a whole new profile record with a new record id, we will have profile record persists
    func updateProfile(){
        guard isValidProfile() else {
            alertItem = AlertContext.invalidProfile
            return
        }

        guard let profileRecord = existingProfileRecord else {
            alertItem = AlertContext.unableToGetProfile
            return
        }

        profileRecord[DDGProfile.kFirstName]    = firstName
        profileRecord[DDGProfile.kLastName]     = lastName
        profileRecord[DDGProfile.kBio]          = bio
        profileRecord[DDGProfile.kCompanyName]  = companyName
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()

        showLoadingView()
        CloudKitManager.shared.save(record: profileRecord) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                    case .success(_):
                        alertItem = AlertContext.updateProfileSuccess
                    case .failure(_):
                        alertItem = AlertContext.updateProfileFailure
                }
            }
        }
    }

    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName]    = firstName
        profileRecord[DDGProfile.kLastName]     = lastName
        profileRecord[DDGProfile.kBio]          = bio
        profileRecord[DDGProfile.kCompanyName]  = companyName
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()

        return profileRecord
    }
    
    private func showLoadingView(){
        isLoading = true
    }
    private func hideLoadingView(){
        isLoading = false
    }
}
