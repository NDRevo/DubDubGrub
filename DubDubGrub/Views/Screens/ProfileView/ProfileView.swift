//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI
import CloudKit

struct ProfileView: View {

    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack{
            VStack(){
                ZStack {
                    NameBackgroundView()
                    
                    HStack(spacing: 16) {
                        ZStack {
                            AvatarView(size: 84, image: viewModel.avatar)
                            EditImage()
                        }
                        .padding(.leading, 12)
                        .onTapGesture { viewModel.isShowingPhotoPicker = true }
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(Text("Profile Photo"))
                        .accessibilityHint(Text("Opens the iPhone's photo picker"))
                        
                        VStack(spacing: 1) {
                            TextField("First Name", text: $viewModel.firstName)
                                .profileNameTextStyle()
                            TextField("Last Name", text: $viewModel.lastName)
                                .profileNameTextStyle()
                            TextField("Company Name", text: $viewModel.companyName)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        CharactersRemainView(currentCount: viewModel.bio.count)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        if viewModel.isCheckedIn {
                            Button {
                                viewModel.checkOut()
                            } label: {
                                Label("Check Out", systemImage: "mappin.and.ellipse")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(height: 28)
                                    .background(Color.grubRed)
                                    .cornerRadius(8)
                            }
                            .accessibilityLabel(Text("Check out of current location."))
                        }
                    }
                    TextEditor(text: $viewModel.bio)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1))
                        .accessibilityHint("This TextField is for your bio and has a 100 character maximum.")
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button {
                    viewModel.profileContext == .create ? viewModel.createProfile() : viewModel.updateProfile()
                } label: {
                    //Turnerary operator: WTF, what, true, false
                    DDGButton(title: viewModel.profileContext == .create ? "Create Profile" : "Update Profile")
                }
                .padding(.bottom)
                
            }
            if viewModel.isLoading {LoadingView()}
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(DeviceTypes.isiPhone8Standard ? .inline : .automatic)
        .toolbar{
            Button {
                dismissKeyboard()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
            }
        }
        .onAppear {
            viewModel.getCheckedInStatus()
            viewModel.getProfile()
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .sheet(isPresented: $viewModel.isShowingPhotoPicker) {
            PhotoPicker(image: $viewModel.avatar)
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
