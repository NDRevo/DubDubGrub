//
//  DubDubGrubApp.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

@main
struct DubDubGrubApp: App {

    let locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(locationManager)
        }
    }
}
