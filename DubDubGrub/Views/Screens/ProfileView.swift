//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var firstName    = ""
    @State private var lastName     = ""
    @State private var companyName  = ""
    @State private var bio          = ""
    @State private var avatar       = PlaceholderImage.avatar
    
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
                    
                } label: {
                    DDGButton(title: "Create Profile")
                }
             
            }
            .navigationTitle("Profile")
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
