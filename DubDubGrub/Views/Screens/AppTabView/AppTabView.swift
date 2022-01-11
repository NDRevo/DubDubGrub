//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct AppTabView: View {
    
    @StateObject private var viewModel = AppTabViewModel()
    
    var body: some View {
        TabView {
            LocationMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            LocationListView()
                .tabItem {
                    Label("Locations", systemImage: "building.2.fill")
                }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }

        }
        .onAppear {
            CloudKitManager.shared.getUserRecord()
            viewModel.runStartupChecks()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView,onDismiss: viewModel.checkIfLocationServicesIsEnabled) {
            OnboardView()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
