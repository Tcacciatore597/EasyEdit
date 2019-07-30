//
//  PlayVideoViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/29/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class PlayVideoViewController: UIViewController {


    @IBAction func playVideoButtonTapped(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)

    }

}

// MARK: - UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else {
                return
        }
        
        // 2
        dismiss(animated: true) {
            //3
            let player = AVPlayer(url: url)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
}

