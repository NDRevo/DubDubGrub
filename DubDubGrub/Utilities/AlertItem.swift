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
    
    //MARK: - ProfileView Errors
    
    static let invalidProfile       = AlertItem(title: Text("Invalid Profile"),
                                                message: Text("All fields are required as well as a profile photo. Your bio must be <100 characters. \nPlease try again."),
                                                dismissButton: .default(Text("Ok")))
    //Not logged into iCloud
    static let noUserRecord         = AlertItem(title: Text("No User Record"),
                                                message: Text("You must log into iCloud on your phone in order to utilize Dub Dub Grub's Profile"),
                                                dismissButton: .default(Text("Ok")))
    //Successfully created profile
    static let createProfileSuccess = AlertItem(title: Text("Profile Created Successfully!"),
                                                message: Text("Your profile has successfully been created!"),
                                                dismissButton: .default(Text("Ok")))
    //Failed to created profile
    static let createProfileFailure = AlertItem(title: Text("Failed to create profile!"),
                                                message: Text("We were unable to crete your profile at this time. \n Please try again later."),
                                                dismissButton: .default(Text("Ok")))
    //Failed to get profile
    static let unableToGetProfile   = AlertItem(title: Text("Unable to Retrieve Profile"),
                                                message: Text("We were unable to retrieve your profile at this time. \n Please check your internet connection and try again later."),
                                                dismissButton: .default(Text("Ok")))
    //Failed to get profile
    static let updateProfileSuccess = AlertItem(title: Text("Profile Update Success!"),
                                                message: Text("Your profile was updated successfully!"),
                                                dismissButton: .default(Text("Bet")))
    //Failed to get profile
    static let updateProfileFailure = AlertItem(title: Text("Profile Update Failed"),
                                                message: Text("We were unable to update your profile at this time. Please try again later."),
                                                dismissButton: .default(Text("Ok")))
    
}
