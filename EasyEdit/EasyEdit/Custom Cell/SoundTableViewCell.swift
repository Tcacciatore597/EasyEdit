//
//  SoundTableViewCell.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/31/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import AVFoundation


class SoundTableViewCell: UITableViewCell {
    
    @IBOutlet weak var soundTitleLabel: UILabel!
    @IBOutlet weak var addSoundButton: UIButton!
    
    
    var sound: Sound? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        if let sound = sound {
            soundTitleLabel.text = sound.title
        }
    }

    @IBAction func addSoundButtonTapped(_ sender: Any) {
       
    
    }
    

}
