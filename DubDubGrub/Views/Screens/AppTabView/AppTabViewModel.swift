//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/6/22.
//

import Foundation
import SwiftUI

//NSObject for CLLocationManagerDelegate

extension AppTabView {
    final class AppTabViewModel: ObservableObject{
        @Published var isShowingOnboardView = false
        @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
            didSet {
                isShowingOnboardView = hasSeenOnboardView
            }
        }

        let kHasSeenOnboardView: String = "hasSeenOnboardView"
        
        func checkIfHasSeenOnBoard(){
            if !hasSeenOnboardView {
                hasSeenOnboardView = true
            }
        }
    }
}
