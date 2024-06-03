//
//  CallingGroupChannelViewController.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import UIKit
import SendbirdUIKit
import SendBirdCalls

class CallingGroupChannelViewController: SBUGroupChannelViewController {
    
}


class CalllinGroupChannelListModule: SBUGroupChannelListModule {
    
}
class CallIncomingMessageCell: SBUContentBaseMessageCell {
//    var callInfo: CallInfo? {
//        didSet {
//            guard let info = self.callInfo else { return }
//            
//            if info.isVideoCall {
//                self.callTypeImageView.image = UIImage(named: "icCallVideoFilled_Incoming")
//            } else {
//                self.callTypeImageView.image = UIImage(named: "icCallFilled_Incoming")
//            }
//            
//            
//            if let duration = info.duration,
//               let reason = info.endResult {
//                switch reason {
//                case .completed:
//                    self.textMessageLabel.text = "\(duration.timerText())"
//                case .unknown, .none:
//                    self.textMessageLabel.text = "Unknown Error"
//                default:
//                    self.textMessageLabel.text = reason.capitalized().replacingOccurrences(of: "_", with: " ")
//                }
//            } else {
//                self.textMessageLabel.text = "\(info.isVideoCall ? "Video" : "Voice") calling..."
//            }
//        }
//    }
//    
//    override func setupViews() {
//        super.setupViews()
//        
//        // Insert myLabel view inside mainContainerView of SBUUserMessageCell.
//        self.mainContainerView.addArrangedSubview(myLabel)
//    }
//    
//    override func configure(with configuration: SBUBaseMessageCellParams) {
//        super.configure(with: configuration)
//        
//        guard let configuration = configuration as? SBUUserMessageCellParams else { return }
//        guard let userMessage = configuration.userMessage else { return }
//
////        myLabel.text = {YOUR_DATA}
//    }
}

// Register the custom message cell before presenting the group channel view controller.
//groupChannelVC.listComponent?.register(userMessageCell: MyUserMessageCell())
