//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct LocationListView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationListViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State private var onAppearHasFired = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: viewModel.createLocationDetailView(for: location, in: dynamicTypeSize)) {
                        //If no one is checked in at a location, then have a default value of an empty array
                        LocationCell(location: location, profiles: viewModel.checkedInProfiles[location.id, default: []])
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                    }
                }
            }
            .alert(item: $viewModel.alertItem, content: { $0.alert })
            .task{
                if !onAppearHasFired {
                    viewModel.getCheckedInProfileDictionary()
                    onAppearHasFired = true
                }
            }
            .navigationTitle("Grub Spots")
            .listStyle(.plain)
        }
        .refreshable {
            viewModel.getCheckedInProfileDictionary()
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}


