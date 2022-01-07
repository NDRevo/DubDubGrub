//
//  LocationManager.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import Foundation

final class LocationManager: ObservableObject {
    @Published var locations: [DDGLocation] = []
    var selectedLocation: DDGLocation?
}
