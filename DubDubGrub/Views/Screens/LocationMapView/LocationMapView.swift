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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    DDGAnnotation(location: location, number: viewModel.checkedInProfiles[location.id, default: 0])
                        .onTapGesture {
                            locationManager.selectedLocation = location
                            viewModel.isShowingDetailView = true
                        }
                }
            }
            .accentColor(.grubRed)
            .ignoresSafeArea()
            
            LogoView(frameWidth: 70)
                .shadow(radius: 10)
//                    .accessibilityHidden(true) Hides the UI element
        }
        .sheet(isPresented: $viewModel.isShowingDetailView) {
            if let location = locationManager.selectedLocation {
                NavigationView{
                    viewModel.createLocationDetailView(for: location, in: dynamicTypeSize)
                        .toolbar { Button("Dismiss") { viewModel.isShowingDetailView = false } }
                }
            }
        }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .onAppear {
            //Runs concurrently because both trigger UI update, count will be saved untl locations have been retrieved and vice versa
            if locationManager.locations.isEmpty {
                viewModel.getLocations(for: locationManager)
            }

            viewModel.getCheckedInLocationCount()
        }
    }
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
            .environmentObject(LocationManager())
    }
}
