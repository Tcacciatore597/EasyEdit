//
//  SoundController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/31/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import Foundation

class SoundController {
    
    var sounds: [Sound] = [
        Sound(title: "Wow", url: URL(fileURLWithPath: Bundle.main.path(forResource: "wow", ofType: "wav")!)),
        Sound(title: "Failure", url: URL(fileURLWithPath: Bundle.main.path(forResource: "failure", ofType: "wav")!)),
        Sound(title: "Success", url: URL(fileURLWithPath: Bundle.main.path(forResource: "success", ofType: "mp3")!))
    ]
}
