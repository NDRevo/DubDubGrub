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
    
    func embedInScrollView() -> some View {
        GeometryReader { geometry in
            ScrollView {
                //Min is size of the screen, max is infinity cause it can scroll infinitly
                self.frame(minHeight: geometry.size.height, maxHeight: .infinity)
            }
            
        }
    }
}
