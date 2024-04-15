//
//  Debouncer.swift
//  CoreMLSample
//
//  Created by segev perets on 15/03/2024.
//

import Foundation
class Debouncer {
    
    private var isShown: Bool = false
    
    private var timer: Timer?
    let interval: Double
    
    private var hideTimer: Timer?
    private var timeUntilHidden: Double
    
    private var showFunc: ()-> Void
    private var hideFunc: ()-> Void
    
    private func hideInTwoSeconds() {
        hideTimer = Timer.scheduledTimer(withTimeInterval: timeUntilHidden, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            hideFunc()
            self.isShown = false
        }
    }
    
    ///debounce show func when already shown, show immidiently when hidden. also set 2 sec timer and hides, unless show is called again.
    func show() {
        if isShown {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.showFunc()
                self.isShown = true
            }
            
        } else {
            showFunc()
        }
        hideTimer?.invalidate()
        hideInTwoSeconds()
    }
    
    init(
        interval: Double = 0.3,
        timeUntilHidden: Double = 2,
        showFunc: @escaping () -> Void,
        hideFunc: @escaping () -> Void
    ) {
        
        self.interval = interval
        self.timeUntilHidden = timeUntilHidden
        self.showFunc = showFunc
        self.hideFunc = hideFunc
    }
}
