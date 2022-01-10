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
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    DDGAnnotation(location: location, number: viewModel.checkedInProfiles[location.id, default: 0])
                        .accessibilityLabel(Text("Map Pin \(location.name) \(viewModel.checkedInProfiles[location.id, default: 0]) People checked in."))
                        .onTapGesture {
                            locationManager.selectedLocation = location
                            viewModel.isShowingDetailView = true
                        }
                }
            }
            .accentColor(.grubRed)
            .ignoresSafeArea()
            
            VStack {
                LogoView(frameWidth: 70)
                    .shadow(radius: 10)
//                    .accessibilityHidden(true) Hides the UI element
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetailView) {
            if let location = locationManager.selectedLocation {
                NavigationView{
                    viewModel.createLocationDetailView(for: location, in: sizeCategory)
                        .toolbar { Button("Dismiss") { viewModel.isShowingDetailView = false }.accentColor(.brandPrimary) }
                }
            }
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
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
    }
}
