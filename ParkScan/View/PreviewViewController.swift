//
//  PreviewViewController.swift
//  ParkScan
//
//  Created by segev perets on 16/03/2024.
//

import UIKit
import Combine
import Lottie

@MainActor
class PreviewViewController: UIViewController {
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var selectedImage: UIImage!
    let vm = PreviewViewModel()
    var listener = Set<AnyCancellable>()
    var lottie: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewImageView.image = selectedImage
        vm.updateImage(selectedImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bind()
        animateImageOut()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener.removeAll()
    }
    
    private func bind() {
        
            self.vm.$imageBase64EncodedString.sink { imageStr in
            guard let imageStr else {return}
                Task {
                    
                    if let answer = await self.vm.askGPT(question: Constants.Prompt.gptImagePrompt, image: imageStr) {
                        
                        self.handleAnswer(answer)
                        Logger.log(answer)
                    } else {
                        DispatchQueue.main.async {
                            self.lottie = self.vm.lottieAnimationView(to: self.view, lottie: .notFound,loopMode: .loop)
                        }
                        
                    }
                    
                    self.activityIndicator.isHidden = true
                }
            }.store(in: &self.listener)
            
            self.vm.$alertController.sink { alert in
                guard let alert else {return}
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }.store(in: &self.listener)
            
        
    }
    
    private func handleAnswer(_ answer:String) {
        
        
        
        if answer.lowercased().contains("paid") {
            self.lottie = vm.lottieAnimationView(to: view, lottie: .paid)
        } else if answer.lowercased().contains("forbidden") {
            self.lottie = vm.lottieAnimationView(to: view, lottie: .forbidden)
        } else if answer.lowercased().contains("free") {
            self.lottie = vm.lottieAnimationView(to: view, lottie: .free,loopMode: .loop)
        } else if answer.lowercased().contains("unclear") {
            self.lottie = vm.lottieAnimationView(to: view, lottie: .unclear,loopMode: .loop)
        } else {
            Logger.log("❌ Weird answer!")
            UIView.animate(withDuration: 0.5) {
                self.answerLabel.text = answer
            }
        }
        
        self.answerLabel.text = answer
    }
    
    private func animateImageOut() {
        UIView.animate(withDuration: 0.1, delay: 0.3) {
            self.previewImageView.transform = .init(scaleX: 1, y: 0.01)
            self.previewImageView.alpha = 0.001
        } completion: { _ in
            self.activityIndicator.isHidden = false
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
        
        
    }
    
    @IBAction func tryAgainPressed(_ sender: UIButton) {
        
        if let navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
}
