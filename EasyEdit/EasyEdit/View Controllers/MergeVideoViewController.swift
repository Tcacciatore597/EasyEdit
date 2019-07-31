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
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var videoURL: URL?
    var userSelectedTime: Double?
    var firstAsset: AVAsset?
    var audioAsset: AVAsset?
    var isPlaying = false
    
    
    @IBOutlet weak var stopPlayButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var loadAudioButton: UIButton!
    @IBOutlet weak var mergeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoSlider.value = 0
        stopPlayButton.isHidden = true
        videoSlider.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        mergeButton.isHidden = true
        loadAudioButton.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        createPlayerView()
        stopPlayButton.setTitle("Play", for: .normal)
        if firstAsset != nil && audioAsset != nil {
            mergeButton.isHidden = false
        } else if firstAsset != nil {
            loadAudioButton.isHidden = false
        }
    }
    
    @IBAction func stopPlayButtonTapped(_ sender: Any) {
        
        handlePause()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        handleSliderChange()
    }
    
    func handlePause() {
        if isPlaying {
            player?.pause()
            stopPlayButton.setTitle("Play", for: .normal)
        } else {
            player?.play()
            stopPlayButton.setTitle("Pause", for: .normal)
        }
        isPlaying.toggle()
    }
    
    func savedPhotosAvailable() -> Bool {
        guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }
        
        let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return false
    }
    
    func createPlayerView() {
        
        guard let videoURL = videoURL else { return }
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        var topRect = self.view.bounds
        topRect.size.width = topRect.width
        topRect.size.height = topRect.height / 2
        topRect.origin.y = view.layoutMargins.top
        playerLayer!.frame = topRect
        playerLayer!.backgroundColor = UIColor.black.cgColor
        self.view!.layer.addSublayer(playerLayer!)
//        player?.play()
        
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
//        player?.removeTimeObserver(self)
        let interval = CMTime(value: 1, timescale: 2)
        self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {  (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            
            self.timeElapsedLabel.text = "\(minutesString):\(secondsString)"
            
            //lets move the slider thumb
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.videoSlider.value = Float(seconds / durationSeconds)

            }
            
        })
        
    }
    
    func handleSliderChange() {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            self.userSelectedTime = Double(value)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            stopPlayButton.isHidden = false
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                if secondsText < 10 {
                    durationLabel.text = "\(minutesText):0\(secondsText)"
                } else {
                    durationLabel.text = "\(minutesText):\(secondsText)"

                }

            }
        }
    }

    func exportDidFinish(_ session: AVAssetExportSession) {
        
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
        
        // Library permission
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
  
    
    @IBAction func loadVideoAssetButtonTapped(_ sender: Any) {
        if savedPhotosAvailable() {
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SoundClipSegue" {
            let vc = segue.destination as! SoundClipsTableViewController
            vc.delegate = self
        }
    }
    
    
    @IBAction func loadAudioAssetButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func mergeVideoButtonTapped(_ sender: Any) {
        
        
        let mixComposition = AVMutableComposition()
        
        guard
            let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else {
                return
            }
        guard let firstAsset = firstAsset else { return }
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: firstAsset.duration),
                                           of: (firstAsset.tracks(withMediaType: AVMediaType.video)[0]),
                                           at: CMTime.zero)
        } catch {
            print("Failed to load first track")
            return
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,
                                                    duration: firstAsset.duration)
        
        let firstInstruction = VideoHelper.videoCompositionInstruction(firstTrack, asset: firstAsset)
        
        mainInstruction.layerInstructions = [firstInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        if let loadedAudioAsset = audioAsset {
            guard let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0) else { return }
            do {
                
                try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                duration: loadedAudioAsset.duration),
                                                of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                                at: CMTime(seconds: userSelectedTime ?? 0.0, preferredTimescale: CMTimeScale(1.0)))
                //Change above code at: CMTime to adjust when the audio is played.
                
            } catch {
                print("Failed to load Audio track")
            }
        }
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
                                                                return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
                                                    return
        }
        
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
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
        firstAsset = avAsset
        videoURL = url
    }
}

extension MergeVideoViewController: UINavigationControllerDelegate {
    
}

//extension MergeVideoViewController: MPMediaPickerControllerDelegate {
//
//    func mediaPicker(_ mediaPicker: MPMediaPickerController,
//                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//
//        dismiss(animated: true) {
//            let selectedSongs = mediaItemCollection.items
//            guard let song = selectedSongs.first else { return }
//
//            let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
//            self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
//            let title = (url == nil) ? "Asset Not Available" : "Asset Loaded"
//            let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
//
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}

extension MergeVideoViewController: AssetDelegate {
    func assetUrlSelected(url: URL) {
        self.audioAsset = AVAsset(url: url)
        print("The Url was passed!")
    }
}



