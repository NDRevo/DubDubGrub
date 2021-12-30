//
//  AlertItem.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    //MARK: - MapView Errors
    
    static let unableToGetLocations = AlertItem(title: Text("Locations Error"),
                                                message: Text("Unable to retrieve locations at this time. \nPlease try again."),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationsRestricted  = AlertItem(title: Text("Locations Restricted"),
                                                message: Text("Your location is restricted. This may be due to parental controls"),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationsDenied      = AlertItem(title: Text("Locations Denied"),
                                                message: Text("Dub Dub Grub does not have permission to access your location. To change that go to Settings > Dub Dub Grub > Location"),
                                                dismissButton: .default(Text("Ok")))
    
    static let locationsDisabled    = AlertItem(title: Text("Locations Disabled"),
                                                message: Text("Locations services are disabled. Go to your Settings > Privacy > Location Services to turn it on"),
                                                dismissButton: .default(Text("Ok")))
}
