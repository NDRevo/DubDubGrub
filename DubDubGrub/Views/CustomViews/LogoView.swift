//
//  LogoView.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/2/22.
//

import SwiftUI

struct LogoView: View {

    var frameWidth: CGFloat
    
    var body: some View {
        //Decorative so VoiceOver doesn't ready
        Image(decorative: "ddg-map-logo")
            .resizable()
            .scaledToFit()
            .frame(height: frameWidth)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(frameWidth: 250)
    }
}
