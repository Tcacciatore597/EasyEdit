//
//  SoundClipsTableViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/31/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import AVFoundation

protocol AssetDelegate {
    func assetUrlSelected(url: URL)
}

class SoundClipsTableViewController: UITableViewController {

   
    var audioPlayer = AVAudioPlayer()
    var chosenSound: URL?
    var delegate: AssetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SoundController.shared.sounds.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath) as? SoundTableViewCell else { fatalError() }
        let sound = SoundController.shared.sounds[indexPath.row]
        cell.sound = sound
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sound = SoundController.shared.sounds[indexPath.row]
        chosenSound = sound.url
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: sound.url)
            audioPlayer.prepareToPlay()
        } catch {
            NSLog("Error: Audio Player unable to play sound")
        }
        audioPlayer.play()
    }
    
    @IBAction func doneButtonTappee(_ sender: Any) {
        guard let chosenSound = chosenSound else { return }
        delegate?.assetUrlSelected(url: chosenSound)
        
        navigationController?.popViewController(animated: true)
    }
    
}

