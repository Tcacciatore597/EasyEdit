//
//  MergeVideoViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/29/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import AVFoundation

class MergeVideoViewController: UIViewController {

    var audioPlayer = AVAudioPlayer()
    
    func playSaveSound(){
        let path = Bundle.main.path(forResource: "failure.wav", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("couldn't load the file")
        }
    }
  
    @IBAction func mergeVideoButtonTapped(_ sender: Any) {
        
        playSaveSound()
        
    }
    
   

}
