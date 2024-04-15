//
//  VideoViewController.swift
//  CoreMLSample
//
//  Created by Segev on 14/03/2024.
//

import UIKit
import AVFoundation
import Vision

class VideoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, VideoViewModelDelegate {
    

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var captureButton: CustomButton!
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var continueButton: CustomButton!
    internal var videoViewModel: VideoViewModel?
    private var selectedImage: UIImage?
    private var isTryingAgain: Bool = false
    private var debounce: Debouncer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debounce = .init(
            showFunc: showButton,
            hideFunc: hideButton
        )
        
        self.sheetPresentationController?.detents = [.large()]

        self.sheetPresentationController?.prefersGrabberVisible = true
        
        videoViewModel = .init(view: previewView,model: .Inceptionv3)
        videoViewModel?.delegate = self
        self.captureButton.transform = .init(scaleX: 0, y: 0)
        self.continueButton.transform = .init(scaleX: 0, y: 0)
        self.captureButton.titleLabel?.textAlignment = .center
        showDebugLabel()
    }
    
    private func showDebugLabel() {
        #if(DEBUG)
        debugLabel.isHidden = false
        #else
        debugLabel.isHidden = true
        #endif
    }
    
    private func updateDebugLabel(with text:String) {
        #if(DEBUG)
        debugLabel.text = text
        #endif
    }
    
    private func isSign(_ predictions:[String]) -> Bool {
        if predictions.contains(where: { $0.lowercased().contains("sign") 
            || $0.lowercased().contains("scoreboard")
            || $0.lowercased().contains("ruler") }) {
            return true
        }
        return false
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        guard !isTryingAgain else {
            videoViewModel?.startVideo()
            isTryingAgain = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.hideButton()
            }
            return
        }
        
        guard selectedImage != nil else {fatalError("no image")}
        
        videoViewModel?.stopVideo()
        UIView.animate(withDuration: 0.3) {
            self.continueButton.transform = .init(scaleX: 1, y: 1)
        }
        captureButton.setTitle("Try again", for: .normal)
        
        self.isTryingAgain = true
        
    }
    
    @IBAction func continuePressed(_ sender: UIButton) {
        isTryingAgain = false
        performSegue(withIdentifier: Constants.Segue.continueSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.continueSegue {
            
            let destVC = segue.destination as! PreviewViewController
            
            destVC.selectedImage = selectedImage
        }
    }
    ///DO NOT CALL DIRECTLY, call debouncer.show() instead
    private func showButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.captureButton.transform = .init(scaleX: 1, y: 1)
            }
        }
    }
    
    
    private func hideButton() {
        guard let videoViewModel else {return}
        Logger.log("isSessionRunning? ",videoViewModel.isSessionRunning)
        Logger.log("isTryingAgain? ",isTryingAgain)
        guard videoViewModel.isSessionRunning else {return}

        UIView.animate(withDuration: 0.3) {
            self.captureButton.transform = .init(scaleX: 0.001, y: 0.001)
            self.continueButton.transform = .init(scaleX: 0.001, y: 0.001)
        } completion: { _ in
            self.captureButton.setTitle("Capture", for: .normal)
        }
        
    }
    
    //MARK: - VideoViewModelDelegate funcs
    func VideoViewModeldidUpdatePrediction(_ videoViewModel: VideoViewModel, _ predictions: [String]) {
        
        DispatchQueue.main.async {
            self.updateDebugLabel(with: predictions.joined(separator: ", "))
        }
        
        if self.isSign(predictions) {
            self.debounce?.show()
        }
    }
    
    func VideoViewModeldidUpdateImage(_ videoViewModel: VideoViewModel, _ image: UIImage) {
        self.selectedImage = image
    }
    
    func VideoViewModeldidFinishSetup(_ videoViewModel: VideoViewModel) {
        videoViewModel.startVideo()
    }
    
    
}


