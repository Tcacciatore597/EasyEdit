//
//  HomeViewController.swift
//  EasyEdit
//
//  Created by Thomas Cacciatore on 8/1/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import MobileCoreServices

class HomeViewController: UIViewController {

    @IBOutlet weak var recordVideoButton: UIButton!
    
    @IBOutlet weak var createVideoButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        setAppearance()
       
    }
    
    @IBAction func recordVideoButtonTapped(_ sender: Any) {
        
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)

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
