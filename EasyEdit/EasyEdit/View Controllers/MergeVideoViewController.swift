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
import AVKit
import AssetsLibrary

class MergeVideoViewController: UIViewController {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var videoURL: URL?
    var audioURL: URL?
    var userSelectedTime: Int64 = 0
    var userTimeScale: Int32 = 0
    var firstAsset: AVAsset?
    var audioAsset: AVAsset?
    var isPlaying = false
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loadVideoButton: UIButton!
    @IBOutlet weak var stopPlayButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var loadAudioButton: UIButton!
    @IBOutlet weak var mergeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        videoSlider.value = 0
        stopPlayButton.isHidden = true
        videoSlider.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        mergeButton.isHidden = true
        loadAudioButton.isHidden = true
        timeElapsedLabel.isHidden = true
        durationLabel.isHidden = true
        videoSlider.isHidden = true
        instructionLabel.isHidden = true
        imageView.image = UIImage(named: "filmImage")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        createPlayerView()
        stopPlayButton.setTitle("Play", for: .normal)
        if firstAsset != nil && audioAsset != nil {
            durationLabel.isHidden = false
            videoSlider.isHidden = false
            mergeButton.isHidden = false
            timeElapsedLabel.isHidden = false
            instructionLabel.isHidden = false
            titleLabel.isHidden = true
            imageView.isHidden = true
            instructionLabel.text = "Adjust slider for sound clip placement"
        } else if firstAsset != nil {
            centerLabel.isHidden = true
            instructionLabel.isHidden = false
            instructionLabel.text = "Now choose an audio clip"
            loadVideoButton.isHidden = true
            durationLabel.isHidden = false
            timeElapsedLabel.isHidden = false
            videoSlider.isHidden = false
            loadAudioButton.isHidden = false
            titleLabel.isHidden = true
            imageView.isHidden = true
        }
    }
    
    func setAppearance() {
        loadAudioButton.layer.borderColor = UIColor.black.cgColor
        loadAudioButton.layer.borderWidth = 1
        loadAudioButton.layer.cornerRadius = 12
        loadAudioButton.backgroundColor = .lightGray
        
        mergeButton.layer.borderColor = UIColor.black.cgColor
        mergeButton.layer.borderWidth = 1
        mergeButton.layer.cornerRadius = 12
        mergeButton.backgroundColor = .lightGray
        
        loadVideoButton.layer.borderColor = UIColor.black.cgColor
        loadVideoButton.layer.borderWidth = 1
        loadVideoButton.layer.cornerRadius = 12
        loadVideoButton.backgroundColor = .lightGray
        
        stopPlayButton.setImage(UIImage(named: "play"), for: .normal)
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
            stopPlayButton.setImage(UIImage(named: "play"), for: .normal)
            stopPlayButton.setTitle("Play", for: .normal)
        } else {
            player?.play()
            stopPlayButton.setTitle("Pause", for: .normal)
            stopPlayButton.setImage(UIImage(named: "pause"), for: .normal)
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
            player?.seek(to: seekTime)
            self.userSelectedTime = Int64(value)
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            stopPlayButton.isHidden = false
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                guard !(seconds.isNaN || seconds.isInfinite) else {
                    return
                }
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
                let message = success ? "Video saved to Photo Library" : "Failed to save video"
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
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
        //performing the segue. Clean up to work with other button.
    }
    
    
    @IBAction func mergeVideoButtonTapped(_ sender: Any) {
        
     
        mergeVideoAndAudio(videoUrl: videoURL!, audioUrl: audioURL!) { (error, url) in
           print("Merge Done")
        }

}
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()
        
        //start merge
        
        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)
        
        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                        preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        
        mutableCompositionVideoTrack.append(compositionAddVideo!)
        mutableCompositionAudioTrack.append(compositionAddAudio!)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo)
        let userCMTime = CMTimeMake(value: self.userSelectedTime, timescale: 1)
        do {
            if aVideoAsset.duration < aAudioAsset.duration {
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAsset.duration), of: aAudioAssetTrack, at: CMTime.zero)
                
            } else if (aVideoAsset.duration - userCMTime) < aAudioAsset.duration {
                let newAudioDuration = aVideoAsset.duration - userCMTime
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: newAudioDuration), of:aAudioAssetTrack, at: userCMTime)
            } else {
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                duration: aAudioAssetTrack.timeRange.duration),
                of: aAudioAssetTrack,
                at: userCMTime)
            }
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)
            

            
            
            // adding audio (of the video if exists) asset to the final composition
            if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
                try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                           duration: aVideoAssetTrack.timeRange.duration),
                                                                           of: aAudioOfVideoAssetTrack,
                                                                           at: CMTime.zero)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // Exporting
    
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first else {
                                                                return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        
        let savePathUrl: URL = url
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
            print("Old video Deleted.")
        } catch { print(error.localizedDescription) }
        
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
                                                    return
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,
                                                    duration: aVideoAsset.duration)

        let firstInstruction = VideoHelper.videoCompositionInstruction(mutableCompositionVideoTrack.first!, asset: aVideoAsset)

        mainInstruction.layerInstructions = [firstInstruction]
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        let videoComposition = AVMutableVideoComposition(propertiesOf: mixComposition)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        videoComposition.instructions = [mainInstruction]
        exporter.videoComposition = videoComposition
        //Export
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


extension MergeVideoViewController: AssetDelegate {
    func assetUrlSelected(url: URL) {
        audioURL = url
        self.audioAsset = AVAsset(url: url)
    }
}



