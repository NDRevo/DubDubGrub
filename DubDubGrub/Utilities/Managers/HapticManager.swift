//
//  HapticManager.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/10/22.
//

import UIKit

struct HapticManager {
    //Static so we dont have to initialize
    static func playHaptic(with feedbackType: UINotificationFeedbackGenerator.FeedbackType){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedbackType)
    }
}
