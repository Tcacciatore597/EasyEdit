//
//  MergeVideoViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 7/29/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import Photos

class MergeVideoViewController: UIViewController {
    
    var firstAsset: AVAsset?
    var audioAsset: AVAsset?
    
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    func savedPhotosAvailable() -> Bool {
        guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }
        
        let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return false
    }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
        
        // Cleanup assets
        activityMonitor.stopAnimating()
        firstAsset = nil
        audioAsset = nil
        
        guard
            session.status == AVAssetExportSession.Status.completed,
            let outputURL = session.outputURL
            else {
                return
        }
        
        let saveVideoToPhotos = {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            }) { saved, error in
                let success = saved && (error == nil)
                let title = success ? "Success" : "Error"
                let message = success ? "Video saved" : "Failed to save video"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Ensure permission to access Photo Library
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            }
        } else {
            saveVideoToPhotos()
        }
    }

//    var audioPlayer = AVAudioPlayer()
//    
//    func playSaveSound(){
//        let path = Bundle.main.path(forResource: "failure.wav", ofType: nil)!
//        let url = URL(fileURLWithPath: path)
//        
//        do {
//            //create your audioPlayer in your parent class as a property
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer.play()
//        } catch {
//            print("couldn't load the file")
//        }
//    }
  
    
    @IBAction func loadVideoAssetButtonTapped(_ sender: Any) {
        if savedPhotosAvailable() {
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
    }
    
    
    @IBAction func loadAudioAssetButtonTapped(_ sender: Any) {
        
        let path = Bundle.main.path(forResource: "failure.wav", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        self.audioAsset = AVAsset(url: url)
        let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
        let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func mergeVideoButtonTapped(_ sender: Any) {
        
        activityMonitor.startAnimating()
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // 2 - Create two video tracks
        guard
            let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else {
                return
        }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstAsset!.duration),
                                           of: (firstAsset?.tracks(withMediaType: AVMediaType.video)[0])!,
                                           at: CMTime.zero)
        } catch {
            print("Failed to load first track")
            return
        }
        
        
        // 3 - Audio track
        if let loadedAudioAsset = audioAsset {
            let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
            do {
                try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                duration: CMTimeAdd(firstAsset!.duration, firstAsset!.duration)),
                                                of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                                at: CMTime.zero)
            } catch {
                print("Failed to load Audio track")
            }
        }
        
        // 4 - Get path
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
                                                                return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
                                                    return
        }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        
        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter)
            }
        }
        
        
    }
    
   

}

extension MergeVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else { return }
  
        let avAsset = AVAsset(url: url)
        let message = "Video one loaded"
            firstAsset = avAsset
        let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension MergeVideoViewController: UINavigationControllerDelegate {
    
}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        dismiss(animated: true) {
            let selectedSongs = mediaItemCollection.items
            guard let song = selectedSongs.first else { return }
            
            let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
            self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
            let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
            let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
