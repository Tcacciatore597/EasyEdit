//
//  HomeViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 8/1/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class HomeViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var createVideoButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var soundController = SoundController()
    var audioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        recordButton.isHidden = true
        setAppearance()
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordButton.isHidden = false
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setTitle("Tap to Stop", for: .normal)
            SoundController.shared.saveRecordedAudio(url: audioRecorder.url)

            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @IBAction func recordVideoButtonTapped(_ sender: Any) {
        
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)

    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func assignbackground(){
        let background = UIImage(named: "filmCutImage")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func setAppearance() {
        recordVideoButton.layer.borderColor = UIColor.black.cgColor
        recordVideoButton.layer.borderWidth = 1
        recordVideoButton.layer.cornerRadius = 12
        recordVideoButton.backgroundColor = .lightGray
        
        createVideoButton.layer.borderColor = UIColor.black.cgColor
        createVideoButton.layer.borderWidth = 1
        createVideoButton.layer.cornerRadius = 12
        createVideoButton.backgroundColor = .lightGray
        
        recordButton.layer.borderColor = UIColor.black.cgColor
        recordButton.layer.borderWidth = 1
        recordButton.layer.cornerRadius = 12
        recordButton.backgroundColor = .lightGray
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }

}

extension HomeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }
        
        UISaveVideoAtPathToSavedPhotosAlbum(
            url.path,
            self,
            #selector(video(_:didFinishSavingWithError:contextInfo:)),
            nil)
        
    }
}

extension HomeViewController: UINavigationControllerDelegate {

}
