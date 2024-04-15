//
//  CustomButton.swift
//  ParkScan
//
//  Created by segev perets on 20/03/2024.
//

import UIKit

@MainActor
class CustomButton: UIButton {
    
    let color: UIColor = .blue
    
    var isGradient: Bool = false {
        didSet {
            if isGradient {
                addGradientLayer()
            }
        }
    }
    
    
    
    private func addGradientLayer(_ colors:[UIColor] = [.blue,.systemBlue]) {
        let gradientLayer = CAGradientLayer()
        let colors: [CGColor] = colors.map{$0.cgColor}
        gradientLayer.colors = colors
        gradientLayer.frame = self.bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .init(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = .init(scaleX: 1, y: 1)
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .init(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = .init(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
}
