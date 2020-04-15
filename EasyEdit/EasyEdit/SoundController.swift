//
//  SoundController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/31/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import Foundation

class SoundController {
    
    static let shared = SoundController()
    
    var sounds: [Sound] = [
        Sound(title: "Wow", url: URL(fileURLWithPath: Bundle.main.path(forResource: "wow", ofType: "wav")!)),
        Sound(title: "Doom", url: URL(fileURLWithPath: Bundle.main.path(forResource: "doom", ofType: "wav")!)),
        Sound(title: "Success", url: URL(fileURLWithPath: Bundle.main.path(forResource: "success", ofType: "mp3")!)),
        Sound(title: "Rock Beat", url: URL(fileURLWithPath: Bundle.main.path(forResource: "rockbeat", ofType: "aiff")!))
    ]
    
    func saveRecordedAudio(url: URL) {
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm a"
        let dateText = dateFormatter.string(from: now)
        SoundController.shared.sounds.append(Sound(title: "New Recording: \(dateText)", url: url))
    }
    
    func removeOldRecording() {
        if SoundController.shared.sounds.count > 3 {
            SoundController.shared.sounds.removeLast()
        }
    }
}
