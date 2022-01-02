//
//  LocationMapView.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI
import MapKit

struct LocationMapView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationMapViewModel()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapMarker(coordinate: location.location.coordinate, tint: .brandPrimary)
            }
            .accentColor(.grubRed)
            .ignoresSafeArea()
            
            VStack {
                LogoView(frameWidth: 70)
                    .shadow(radius: 10)
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView,onDismiss: viewModel.checkIfLocationServicesIsEnabled) {
            OnboardView(isShowingOnboardView: $viewModel.isShowingOnboardView)
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .onAppear {
            viewModel.runStartupChecks()
            
            if locationManager.locations.isEmpty{
                viewModel.getLocations(for: locationManager)
            }
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
