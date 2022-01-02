//
//  XDismissButton.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/2/22.
//

import SwiftUI

struct XDismissButton: View {
    var body: some View {
        ZStack{
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(.brandPrimary)
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .imageScale(.small)
                .frame(width: 44, height: 44) //Increasing touch target size
        }
    }
}

struct XDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        XDismissButton()
    }
}
