//
//  CallingViewController.swift
//  CalsChatSample
//
//  Created by Minhyuk Kim on 2024/05/31.
//  Copyright © 2024 SendBird. All rights reserved.
//

import UIKit
import SendBirdCalls
import AVKit

class CallingViewController: UIViewController {
    
    @IBOutlet weak var localVideoView: UIView!
    
    @IBOutlet weak var remoteUserLabel: UILabel! {
        didSet {
            let nickname = self.call.remoteUser?.nickname
            if nickname?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                self.remoteUserLabel.text = self.call.remoteUser?.userId
            } else {
                self.remoteUserLabel.text = nickname
            }
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var remoteMuteImage: UIImageView!
    @IBOutlet weak var remoteMuteStatusLabel: UILabel!

    @IBOutlet weak var flipCameraButton: UIButton!
    @IBAction func didTapFlipCameraButton(_ sender: Any) {
        self.call.switchCamera { (error) in
            guard error == nil else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.presentErrorAlert(message: error?.localizedDescription ?? "")
                }
                return
            }
        }
    }
    
    @IBOutlet weak var muteButton: UIButton! {
        didSet {
            self.muteButton.isSelected = !self.call.isLocalAudioEnabled
        }
    }
    @IBAction func didTapMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            self.cameraButton.isSelected = !self.call.isLocalVideoEnabled
        }
    }
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalVideo(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEndButton(_ sender: Any) {
        self.call.end()
    }
    @IBOutlet weak var cameraButtonWidthConstraint: NSLayoutConstraint!
    
    var call: DirectCall!
    var callTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.call.delegate = self
        
        self.updateRemoteAudio(isEnabled: true)
        self.setUpView()
        
        if call.customItems["isConnected"] != nil {
            self.statusLabel.isHidden = true
            self.remoteUserLabel.isHighlighted = (true && self.call.isVideoCall)
        }
    }
    
    func setUpView() {
        if self.call.isVideoCall {
            self.setupVideoView()
            
            self.remoteUserLabel.isHidden = true
        } else {
            self.localVideoView.isHidden = true
            self.flipCameraButton.isHidden = true
            self.cameraButton.isHidden = true
            self.cameraButtonWidthConstraint.constant = 0
        }
    }
    
    func setupVideoView() {
        DispatchQueue.main.async { [self] in
            let localSBVideoView = SendBirdVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
            let remoteSBVideoView = SendBirdVideoView(frame: self.view?.frame ?? CGRect.zero)
            
            self.call.updateLocalVideoView(localSBVideoView)
            self.call.updateRemoteVideoView(remoteSBVideoView)
            
            self.localVideoView?.embed(localSBVideoView)
            self.view?.embed(remoteSBVideoView)
            
            self.mirrorLocalVideoView(isEnabled: true)
        }
    }
    
    func mirrorLocalVideoView(isEnabled: Bool) {
        guard let localSBView = self.localVideoView?.subviews.first else { return }
        switch isEnabled {
        case true: localSBView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        case false: localSBView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func updateLocalVideo(isEnabled: Bool) {
        let image = isEnabled ? UIImage(named: "btnVideoOffSelected") : UIImage(named: "btnVideoOff")
        self.cameraButton.setBackgroundImage(image!, for: .normal)
        if isEnabled {
            call.stopVideo()
            self.localVideoView?.subviews.first?.isHidden = true
        } else {
            call.startVideo()
            self.localVideoView?.subviews.first?.isHidden = false
        }
    }
    
    func updateLocalAudio(isEnabled: Bool) {
        let image = isEnabled ? UIImage(named: "btnAudioOffSelected") : UIImage(named: "btnAudioOff")
        self.muteButton.setBackgroundImage(image!, for: .normal)
        
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isEnabled: Bool) {
        self.remoteMuteImage.isHidden = isEnabled
        self.remoteMuteStatusLabel.isHidden = isEnabled
    }
    
    func activateTimer() {
        self.statusLabel.text = "00:00"
        
        // Main thread
        self.callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // update UI
            self.statusLabel.text = self.call.duration.durationText()
            
            // Timer Invalidate
            if self.call.endedAt != 0, timer.isValid {
                timer.invalidate()
                self.callTimer = nil
            }
        }
    }
}

extension CallingViewController: DirectCallDelegate {
    // MARK: Required Methods`
    func didConnect(_ call: DirectCall) {
        call.updateCustomItems(customItems: ["isConnected": "true"]) { (_, _, _) in }
        self.remoteUserLabel.isHidden = (true && self.call.isVideoCall)
        
        self.activateTimer()
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
        
        CXCallManager.shared.connectedCall(call)
    }
    
    func didEnd(_ call: DirectCall) {
        defer {
            self.dismiss(animated: true)
        }
        
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        CXCallManager.shared.endCXCall(call)
    }
    
    // MARK: Optional Methods
    func didEstablish(_ call: DirectCall) {
        self.statusLabel.text = "Connecting..."
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        self.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
    }
}

extension UIView {
    func embed(_ videoView: SendBirdVideoView) {
        self.insertSubview(videoView, at: 0)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": videoView]))
        self.layoutIfNeeded()
    }
}
extension Int64 {
    func durationText() -> String {
        let duration = self
        
        let convertedTime = Int(duration / 1000)
        let hour = Int(convertedTime / 3600)
        let minute = Int(convertedTime / 60) % 60
        let second = Int(convertedTime % 60)
        
        // update UI
        var timeText = [String]()
        
        if hour > 0 {
            timeText.append(String(hour))
            timeText.append(String(format: "%02d", minute))
        } else {
            timeText.append(String(format: "%02d", minute))
            timeText.append(String(format: "%02d", second))
        }
        
        return timeText.joined(separator: ":")
    }
}
