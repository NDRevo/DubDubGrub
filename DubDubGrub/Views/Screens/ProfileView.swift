//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI
import CloudKit

struct ProfileView: View {
    
    @State private var firstName    = ""
    @State private var lastName     = ""
    @State private var companyName  = ""
    @State private var bio          = ""
    @State private var avatar       = PlaceholderImage.avatar
    @State private var isShowingPhotoPicker = false
    @State private var alertItem: AlertItem?
    
    var body: some View {
            VStack(){
                ZStack {
                    NameBackgroundView()
                    
                    HStack(spacing: 16) {
                        ZStack {
                            AvatarView(size: 84, image: avatar)
                            EditImage()
                        }
                        .padding(.leading, 12)
                        .onTapGesture { isShowingPhotoPicker = true }
                        
                        VStack(spacing: 1) {
                            TextField("First Name", text: $firstName)
                                .profileNameTextStyle()
                            TextField("Last Name", text: $lastName)
                                .profileNameTextStyle()
                            TextField("Company Name", text: $companyName)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    CharactersRemainView(currentCount: bio.count)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 1))
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button {
                   createProfile()
                } label: {
                    DDGButton(title: "Create Profile")
                }
                .padding(.bottom)
             
            }
            .navigationTitle("Profile")
            .toolbar{
                Button {
                    dismissKeyboard()
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
            .onAppear {
                getProfile()
            }
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            })
            .sheet(isPresented: $isShowingPhotoPicker) {
                PhotoPicker(image: $avatar)
            }
        }
    
    func isValidProfile() -> Bool{
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count < 100 else {
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
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName]    = firstName
        profileRecord[DDGProfile.kLastName]     = lastName
        profileRecord[DDGProfile.kBio]          = bio
        profileRecord[DDGProfile.kCompanyName]  = companyName
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()
        
        //Get our UserRecord ID from Container
        CKContainer.default().fetchUserRecordID{ recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            //Get User record from Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                //Create reference on UserRecord to DDGProfile we created
                userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
                
                //Create CKOPeration to save our User & Profile Records, batch save
                let operation = CKModifyRecordsOperation(recordsToSave: [userRecord,profileRecord])
                operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
                    guard let savedRecords = savedRecords, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    print(savedRecords)
                }
                
                //Add to database
                
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
    }
    
    func getProfile(){
        //Get user record ID
        CKContainer.default().fetchUserRecordID{ recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            //Get User record from Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                //Get reference
                let profileReference = userRecord["userProfile"] as! CKRecord.Reference
                let profileRecordID = profileReference.recordID
                
                //Fetch profile record
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: profileRecordID) { profileRecord, error in
                    guard let profileRecord = profileRecord, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    //Working on back end thread, need to be on main thread
                    DispatchQueue.main.async {
                        let profile = DDGProfile(record: profileRecord)
                        firstName   = profile.firstName
                        lastName    = profile.lastName
                        companyName = profile.companyName
                        bio         = profile.bio
                        avatar      = profile.createAvatarImage()
                    }
                }
            }
        }
    }
}

struct CheckOutButton: View {
    var body: some View {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text("Check Out")
                    .bold()
                
            }
            .font(.caption)
            .accentColor(.white)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .foregroundColor(Color.pink)
                    .frame(height: 30)
            )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ProfileView()
        }
    }
}

struct NameBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .frame( height: 130)
            .foregroundColor(Color(UIColor.secondarySystemBackground))
            .padding(.horizontal)
    }
}

struct EditImage: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
            .foregroundColor(.white)
            .offset(y: 30)
    }
}


struct CharactersRemainView: View {
    var currentCount: Int
    
    var body: some View {
        Text("Bio: ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(100 - currentCount)")
            .bold()
            .font(.callout)
            .foregroundColor(currentCount <= 100 ? .brandPrimary : .pink)
        +
        Text(" Characters remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}
