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

extension ProfileView{
    @MainActor final class ProfileViewModel: ObservableObject {

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
        
        var buttonTitle: String { profileContext == .create ? "Create Profile" : "Update Profile"}

        var profileContext: ProfileContext = .create
        
        func getCheckedInStatus(){
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            
            Task{
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference{
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                    }
                } catch {
                    print("Unable to get checked in status")
                }
            }
        }
        
        func checkOut(){
            guard let profileID = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.unableToGetProfile
                return
            }

            showLoadingView()
            
            Task {
                do {
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileID)
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilChecked] = 0
                    
                    let _ = try await CloudKitManager.shared.save(record: record)
                    HapticManager.playHaptic(with: .success)
                    isCheckedIn = false
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToCheckInOrOut
                }
            }
        }

        private func isValidProfile() -> Bool{
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
        
        func determineButtonAction(){
            profileContext == .create ? createProfile() : updateProfile()
        }

        private func createProfile(){
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
            
            Task {
                do {
                    let records = try await CloudKitManager.shared.batchSave(records: [userRecord,profileRecord])
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        //Makes sure to update profileRecordID when first creating a profile
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    hideLoadingView()
                    alertItem = AlertContext.createProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.createProfileFailure
                }
            }
        }

        func getProfile(){

            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }

            //Get reference, if none it means they havent created a profile
            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
            let profileRecordID = profileReference.recordID

            showLoadingView()
            Task {
                do{
                    let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    existingProfileRecord = record
                    let profile = DDGProfile(record: record)
                    firstName   = profile.firstName
                    lastName    = profile.lastName
                    companyName = profile.companyName
                    bio         = profile.bio
                    avatar      = profile.avatarImage
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.unableToGetProfile
                }
            }
        }

        //Instead of creating a whole new profile record with a new record id, we will have profile record persists
        private func updateProfile(){
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
            profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()

            showLoadingView()
            
            Task {
                do {
                    let _ = try await CloudKitManager.shared.save(record: profileRecord)
                    hideLoadingView()
                    alertItem = AlertContext.updateProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContext.updateProfileFailure
                }
            }
        }

        private func createProfileRecord() -> CKRecord {
            let profileRecord = CKRecord(recordType: RecordType.profile)
            profileRecord[DDGProfile.kFirstName]    = firstName
            profileRecord[DDGProfile.kLastName]     = lastName
            profileRecord[DDGProfile.kBio]          = bio
            profileRecord[DDGProfile.kCompanyName]  = companyName
            profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()

            return profileRecord
        }

        private func showLoadingView(){
            isLoading = true
        }

        private func hideLoadingView(){
            isLoading = false
        }
    }
}
