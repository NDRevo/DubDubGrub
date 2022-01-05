//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/5/22.
//

import Foundation
import CloudKit

final class ProfileViewModel: ObservableObject {

    @Published var firstName    = ""
    @Published var lastName     = ""
    @Published var companyName  = ""
    @Published var bio          = ""
    @Published var avatar       = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var alertItem: AlertItem?

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
            //show alert
            return
        }

        //Create reference on UserRecord to DDGProfile we created
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)

        CloudKitManager.shared.batchSave(records: [userRecord,profileRecord]) { result in
            
            switch result {
            case .success(_):
                //show alert
                break
            case .failure(_):
                //show alert
                break
            }
        }
    }

    func getProfile(){

        guard let userRecord = CloudKitManager.shared.userRecord else {
            return
        }

        //Get reference
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else {
            //show alert
            return
        }

        let profileRecordID = profileReference.recordID

        CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            DispatchQueue.main.async { [self] in
                switch result {

                case .success(let record):
                    //Working on background thread, need to be on main thread
                    let profile = DDGProfile(record: record)
                    firstName   = profile.firstName
                    lastName    = profile.lastName
                    companyName = profile.companyName
                    bio         = profile.bio
                    avatar      = profile.createAvatarImage()
                case .failure(_):
                    //Show alertn
                    break
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
}
