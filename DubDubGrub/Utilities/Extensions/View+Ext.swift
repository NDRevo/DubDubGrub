//
//  View+Ext.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

extension View {
    func profileNameTextStyle() -> some View {
        self.modifier(ProfileNameText())
    }
    
    //Function to dismiss keyboard
    func dismissKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
