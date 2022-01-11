//
//  ProfileSheetView.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

// Alternative Profile Modal View for larger dynamic type sizes
struct ProfileSheetView: View {

    var profile: DDGProfile

    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                Image(uiImage: profile.avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
                Text(profile.firstName + " " + profile.lastName)
                    .bold()
                    .font(.title2)
                    .minimumScaleFactor(0.90)
                Text(profile.companyName)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.90)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Works at \(profile.companyName)")
                
                Text(profile.bio)
                    .accessibilityLabel("Bio, \(profile.bio)")
            }
        }
        .padding()
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheetView(profile: DDGProfile(record: MockData.profile))
            .environment(\.dynamicTypeSize, .accessibility5)
    }
}
