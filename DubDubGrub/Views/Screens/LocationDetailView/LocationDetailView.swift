//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct LocationDetailView: View {
    
    //StateObject for when we initalize a new view model inside the view
    //ObservedObject when view realizes on data from other screen and view model is being passed in from prev screen
    //ObservedObject when passing data from previous screen
    @ObservedObject var viewModel: LocationDetailViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                BannerImageView(image: viewModel.location.bannerImage)
                AddressViewHStack(address: viewModel.location.address)
                DescriptionView(text: viewModel.location.description)
                ActionButtonHStack(viewModel: viewModel)
                GridHeaderTextView(number: viewModel.checkedInProfiles.count)
                AvatarGridView(viewModel: viewModel)
            }
            .accessibilityHidden(viewModel.isShowingProfileModal)
            
            if viewModel.isShowingProfileModal {
                FullScreenBlackTransparentView()
                ProfileModalView(isShowingProfileModal: $viewModel.isShowingProfileModal, profile: viewModel.selectedProfile!)
            }
        }
        .task{
            viewModel.getCheckedInProfiles()
            viewModel.getCheckedInStatus()
        }
        .sheet(isPresented: $viewModel.isShowingSheet) {
            NavigationView {
                ProfileSheetView(profile: viewModel.selectedProfile!)
                    .toolbar { Button("Dismiss") { viewModel.isShowingSheet = false }}
            }
        }
        .alert(item: $viewModel.alertItem, content: {$0.alert})
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailView.LocationDetailViewModel(location: DDGLocation(record: MockData.chipotle)))
        }
        .environment(\.dynamicTypeSize, .accessibility5)
    }
}

fileprivate struct BannerImageView: View {

    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .accessibilityHidden(true)
    }
}

fileprivate struct LocationActionButton: View {

    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
            
        }
    }
}

fileprivate struct AddressViewHStack: View {

    var address: String
    
    var body: some View {
        HStack {
            Label(address, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

fileprivate struct DescriptionView: View {

    var text: String

    var body: some View {
        Text(text)
            .minimumScaleFactor(0.75)
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
    }
}

fileprivate struct ActionButtonHStack: View {
    
    @ObservedObject var viewModel: LocationDetailView.LocationDetailViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                viewModel.getDirectionsToLocation()
            } label: {
                LocationActionButton(color: .brandPrimary, imageName: "location.fill")
            }
            .accessibilityLabel(Text("Get directions"))
            
            Link(destination: URL(string: viewModel.location.websiteURL)!, label: {
                LocationActionButton(color: .brandPrimary, imageName: "network")
            })
                .accessibilityRemoveTraits(.isButton)
                .accessibilityLabel(Text("Go to website"))
            
            Button {
                viewModel.callLocation()
            } label: {
                LocationActionButton(color: .brandPrimary, imageName: "phone.fill")
            }
            .accessibilityLabel(Text("Call location"))
            
            if let _ = CloudKitManager.shared.profileRecordID {
                Button {
                    viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkedOut : .checkedIn)
                } label: {
                    LocationActionButton(color: viewModel.buttonColor, imageName: viewModel.buttonImageTitle)
                }
                .accessibilityLabel(Text(viewModel.buttonA11yLabel))
                .disabled(viewModel.isLoading)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}

fileprivate struct GridHeaderTextView: View {
    
    var number: Int
    
    var body: some View {
        Text("Who's Here?")
           .bold()
           .font(.title2)
           .accessibilityAddTraits(.isHeader)
           .accessibilityLabel(Text("Who's Here? \(number) checked in"))
           .accessibilityHint(Text("Bottom section is scrollable"))
    }
}

struct AvatarGridView: View {
    
    @ObservedObject var viewModel: LocationDetailView.LocationDetailViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        ZStack{
            if viewModel.checkedInProfiles.isEmpty {
                //Empty
                GridEmptyStateTextView()
            } else {
                ScrollView {
                    LazyVGrid(columns: viewModel.determineColumns(for: dynamicTypeSize) , content: {
                        ForEach(viewModel.checkedInProfiles) { profile in
                            FirstNameAvatarView(profile: profile)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.show(profile, in: dynamicTypeSize)
                                    }
                                }
                        }
                    })
                }
            }
            if viewModel.isLoading {LoadingView()}
        }
    }
}

fileprivate struct FullScreenBlackTransparentView: View {
    var body: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
            .opacity(0.9)
            .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.35)))
            .zIndex(1)
            .accessibilityHidden(true)
    }
}


fileprivate struct  FirstNameAvatarView: View {

    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var profile: DDGProfile
    
    var body: some View {
        VStack {
            AvatarView(size: dynamicTypeSize >= .accessibility3 ? 100 : 64, image: profile.avatarImage)
            Text(profile.firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(profile.firstName) \(profile.lastName)"))
        .accessibilityHint(Text("Show's \(profile.firstName)'s profile pop up."))
        .accessibilityAddTraits(.isButton)
    }
}

fileprivate struct GridEmptyStateTextView: View {
    var body: some View {
        VStack{
            Text("Nobody's Here ????")
                .bold()
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 30)
            Spacer()
        }
    }
}
