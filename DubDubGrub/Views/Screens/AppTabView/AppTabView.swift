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
        //Replace onAppear for network calls, gives async context, automatically cancels network call when user changes screens
        .task {
            //If fails, returns nil
            try? await CloudKitManager.shared.getUserRecord()
            viewModel.checkIfHasSeenOnBoard()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView) {
            OnboardView()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
