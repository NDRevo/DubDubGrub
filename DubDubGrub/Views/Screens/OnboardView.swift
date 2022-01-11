//
//  OnboardView.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/2/22.
//

import SwiftUI

struct OnboardView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack{

                Spacer()

                Button {
                    dismiss()
                } label: {
                    XDismissButton()
                }
                .padding()
            }

            Spacer()

            LogoView(frameWidth: 200)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 32) {
                OnboardInfoView(imageName: "building.2.crop.circle",
                                infoTitle: "Restaurant Locations",
                                infoDesc: "Find places to dine around the convention center")
                
                OnboardInfoView(imageName: "checkmark.circle",
                                infoTitle: "Check In",
                                infoDesc: "Let other iOS Devs know where you are")
                
                OnboardInfoView(imageName: "person.2.circle",
                                infoTitle: "Find Friends",
                                infoDesc: "See where other iOS Devs are and join the party")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}

fileprivate struct OnboardInfoView: View {
    var imageName: String
    var infoTitle: String
    var infoDesc: String
    
    var body: some View {
        HStack(spacing: 26){
            Image(systemName: imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.brandPrimary)
            VStack(alignment: .leading, spacing: 4){
                Text(infoTitle)
                    .bold()
                Text(infoDesc)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}
