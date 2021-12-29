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
}
