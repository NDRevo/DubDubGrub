//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct LocationListView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: LocationDetailView(viewModel: LocationDetailViewModel(location: location))) {
                            LocationCell(location: location)
                    }
                }
            }
            .onAppear{
                CloudKitManager.shared.getCheckedInProfilesDictionary { result in
                    switch result {
                    case .success(let checkInProfiles):
                        print(checkInProfiles)
                    case .failure(_):
                        print("ERROR getting back dictionary")
                    }
                }
            }
            .navigationTitle("Grub Spots")
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}


